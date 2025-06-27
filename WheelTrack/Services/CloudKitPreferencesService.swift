import Foundation
import CloudKit
import SwiftUI
import Combine

/// Service de synchronisation CloudKit pour les préférences utilisateur
/// Synchronise automatiquement la langue, devise, unités, etc. sur tous les appareils
@MainActor
class CloudKitPreferencesService: ObservableObject {
    
    static let shared = CloudKitPreferencesService()
    
    // MARK: - CloudKit Configuration
    private let container = CKContainer.default()
    private lazy var privateDatabase = container.privateCloudDatabase
    
    // Record type pour les préférences
    private let preferencesRecordType = "UserPreferences"
    private let preferencesRecordID = CKRecord.ID(recordName: "user_preferences")
    
    // MARK: - Published Properties pour UI réactive
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    
    // MARK: - Types
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error(String)
        
        var isLoading: Bool {
            if case .syncing = self { return true }
            return false
        }
        
        var description: String {
            switch self {
            case .idle:
                return L(("En attente", "Idle"))
            case .syncing:
                return L(("Synchronisation...", "Syncing..."))
            case .success:
                return L(("Synchronisé", "Synced"))
            case .error(let message):
                return L(("Erreur: \(message)", "Error: \(message)"))
            }
        }
        
        var icon: String {
            switch self {
            case .idle:
                return "cloud"
            case .syncing:
                return "arrow.triangle.2.circlepath"
            case .success:
                return "cloud.fill"
            case .error:
                return "cloud.bolt"
            }
        }
        
        var color: Color {
            switch self {
            case .idle:
                return .secondary
            case .syncing:
                return .blue
            case .success:
                return .green
            case .error:
                return .red
            }
        }
    }
    
    // MARK: - Preferences Structure
    struct UserPreferences: Codable {
        let language: String
        let currencySymbol: String
        let distanceUnit: String
        let fuelConsumptionUnit: String
        let hapticFeedbackEnabled: Bool
        let lastModified: Date
        
        init(
            language: String = "fr",
            currencySymbol: String = "€",
            distanceUnit: String = "km",
            fuelConsumptionUnit: String = "L/100km",
            hapticFeedbackEnabled: Bool = true,
            lastModified: Date = Date()
        ) {
            self.language = language
            self.currencySymbol = currencySymbol
            self.distanceUnit = distanceUnit
            self.fuelConsumptionUnit = fuelConsumptionUnit
            self.hapticFeedbackEnabled = hapticFeedbackEnabled
            self.lastModified = lastModified
        }
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var lastKnownPreferences: UserPreferences?
    
    private init() {
        setupCloudKitSubscription()
        startPeriodicSync()
    }
    
    // MARK: - Public Methods
    
    /// Synchronise les préférences vers CloudKit
    func syncPreferences() async {
        await MainActor.run {
            syncStatus = .syncing
            syncError = nil
        }
        
        do {
            let currentPrefs = getCurrentPreferences()
            let record = try await savePreferencesToCloudKit(currentPrefs)
            
            await MainActor.run {
                lastSyncDate = Date()
                lastKnownPreferences = currentPrefs
                syncStatus = .success
                
                // Auto-revert to idle after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if case .success = self.syncStatus {
                        self.syncStatus = .idle
                    }
                }
            }
            
            print("✅ Préférences synchronisées vers CloudKit: \(record.recordID)")
            
        } catch {
            await MainActor.run {
                syncStatus = .error(error.localizedDescription)
                syncError = error.localizedDescription
                
                // Auto-revert to idle after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.syncStatus = .idle
                }
            }
            
            print("❌ Erreur sync CloudKit: \(error)")
        }
    }
    
    /// Récupère les préférences depuis CloudKit
    func fetchPreferences() async {
        await MainActor.run {
            syncStatus = .syncing
        }
        
        do {
            let record = try await privateDatabase.record(for: preferencesRecordID)
            let cloudPrefs = try parsePreferencesFromRecord(record)
            
            // Compare les dates de modification pour éviter les conflits
            let localPrefs = getCurrentPreferences()
            
            if cloudPrefs.lastModified > localPrefs.lastModified {
                // Les préférences cloud sont plus récentes
                await applyPreferences(cloudPrefs)
                await MainActor.run {
                    lastSyncDate = Date()
                    lastKnownPreferences = cloudPrefs
                    syncStatus = .success
                }
                print("✅ Préférences mises à jour depuis CloudKit")
            } else {
                // Les préférences locales sont plus récentes, on les pousse
                await syncPreferences()
            }
            
        } catch CKError.unknownItem {
            // Aucun enregistrement existant, on crée le premier
            print("ℹ️ Aucune préférence CloudKit, création initiale...")
            await syncPreferences()
            
        } catch {
            await MainActor.run {
                syncStatus = .error(error.localizedDescription)
                syncError = error.localizedDescription
            }
            print("❌ Erreur récupération CloudKit: \(error)")
        }
    }
    
    /// Force une synchronisation complète
    func forceSyncNow() async {
        await syncPreferences()
    }
    
    /// Vérifie si CloudKit est disponible
    func checkCloudKitAvailability() async -> Bool {
        do {
            let accountStatus = try await container.accountStatus()
            return accountStatus == .available
        } catch {
            print("❌ CloudKit indisponible: \(error)")
            return false
        }
    }
    
    // MARK: - Private Methods
    
    /// Récupère les préférences actuelles depuis @AppStorage
    private func getCurrentPreferences() -> UserPreferences {
        return UserPreferences(
            language: UserDefaults.standard.string(forKey: "app_language") ?? "fr",
            currencySymbol: UserDefaults.standard.string(forKey: "currency_symbol") ?? "€",
            distanceUnit: UserDefaults.standard.string(forKey: "distance_unit") ?? "km",
            fuelConsumptionUnit: UserDefaults.standard.string(forKey: "fuel_consumption_unit") ?? "L/100km",
            hapticFeedbackEnabled: UserDefaults.standard.bool(forKey: "haptic_feedback_enabled"),
            lastModified: UserDefaults.standard.object(forKey: "preferences_last_modified") as? Date ?? Date()
        )
    }
    
    /// Applique les préférences localement
    private func applyPreferences(_ prefs: UserPreferences) async {
        await MainActor.run {
            UserDefaults.standard.set(prefs.language, forKey: "app_language")
            UserDefaults.standard.set(prefs.currencySymbol, forKey: "currency_symbol")
            UserDefaults.standard.set(prefs.distanceUnit, forKey: "distance_unit")
            UserDefaults.standard.set(prefs.fuelConsumptionUnit, forKey: "fuel_consumption_unit")
            UserDefaults.standard.set(prefs.hapticFeedbackEnabled, forKey: "haptic_feedback_enabled")
            UserDefaults.standard.set(prefs.lastModified, forKey: "preferences_last_modified")
            
            // Notifier LocalizationService du changement de langue
            LocalizationService.shared.currentLanguage = prefs.language
            
            // Feedback haptique pour confirmer la synchronisation
            if prefs.hapticFeedbackEnabled {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }
    }
    
    /// Sauvegarde les préférences dans CloudKit
    private func savePreferencesToCloudKit(_ prefs: UserPreferences) async throws -> CKRecord {
        let record = CKRecord(recordType: preferencesRecordType, recordID: preferencesRecordID)
        
        record["language"] = prefs.language as CKRecordValue
        record["currencySymbol"] = prefs.currencySymbol as CKRecordValue
        record["distanceUnit"] = prefs.distanceUnit as CKRecordValue
        record["fuelConsumptionUnit"] = prefs.fuelConsumptionUnit as CKRecordValue
        record["hapticFeedbackEnabled"] = prefs.hapticFeedbackEnabled as CKRecordValue
        record["lastModified"] = prefs.lastModified as CKRecordValue
        
        // Mettre à jour la date de modification locale
        await MainActor.run {
            UserDefaults.standard.set(Date(), forKey: "preferences_last_modified")
        }
        
        return try await privateDatabase.save(record)
    }
    
    /// Parse les préférences depuis un CKRecord
    private func parsePreferencesFromRecord(_ record: CKRecord) throws -> UserPreferences {
        guard let language = record["language"] as? String,
              let currencySymbol = record["currencySymbol"] as? String,
              let distanceUnit = record["distanceUnit"] as? String,
              let fuelConsumptionUnit = record["fuelConsumptionUnit"] as? String,
              let hapticFeedbackEnabled = record["hapticFeedbackEnabled"] as? Bool,
              let lastModified = record["lastModified"] as? Date else {
            throw CKError(.invalidArguments)
        }
        
        return UserPreferences(
            language: language,
            currencySymbol: currencySymbol,
            distanceUnit: distanceUnit,
            fuelConsumptionUnit: fuelConsumptionUnit,
            hapticFeedbackEnabled: hapticFeedbackEnabled,
            lastModified: lastModified
        )
    }
    
    /// Configure les souscriptions CloudKit pour les mises à jour en temps réel
    private func setupCloudKitSubscription() {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let subscription = CKQuerySubscription(
            recordType: preferencesRecordType,
            predicate: predicate,
            subscriptionID: "preferences-sync-subscription",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        Task {
            do {
                _ = try await privateDatabase.save(subscription)
                print("✅ Souscription CloudKit configurée")
            } catch {
                print("❌ Erreur souscription CloudKit: \(error)")
            }
        }
    }
    
    /// Démarre la synchronisation périodique
    private func startPeriodicSync() {
        // Sync initial après 3 secondes
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            Task {
                await self.fetchPreferences()
            }
        }
        
        // Sync périodique toutes les 5 minutes si l'app est active
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                Task {
                    await self.fetchPreferences()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Convenience Methods

extension CloudKitPreferencesService {
    
    /// Indicateur visuel pour la UI
    var syncStatusIndicator: some View {
        HStack(spacing: 6) {
            Image(systemName: syncStatus.icon)
                .foregroundColor(syncStatus.color)
                .scaleEffect(syncStatus.isLoading ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: syncStatus.isLoading)
            
            if let lastSync = lastSyncDate {
                Text(L(("Sync: \(formatSyncDate(lastSync))", "Sync: \(formatSyncDate(lastSync))")))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text(L(("Jamais synchronisé", "Never synced")))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formatSyncDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        let now = Date()
        let timeInterval = now.timeIntervalSince(date)
        
        if timeInterval < 60 {
            return L(("À l'instant", "Just now"))
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return L(("Il y a \(minutes)m", "\(minutes)m ago"))
        } else if timeInterval < 86400 {
            let hours = Int(timeInterval / 3600)
            return L(("Il y a \(hours)h", "\(hours)h ago"))
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            formatter.locale = Locale(identifier: "fr_FR") // Par défaut en français
            return formatter.string(from: date)
        }
    }
}

 