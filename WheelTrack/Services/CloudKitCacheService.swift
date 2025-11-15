import Foundation
import CloudKit

/// Service de cache partagé CloudKit pour les horaires des garages
/// Permet de réduire les appels à Google Places API en partageant les horaires entre utilisateurs
final class CloudKitCacheService {
    
    // MARK: - Properties
    
    private let database = CKContainer.default().publicCloudDatabase
    private let recordType = "PlaceHoursCache"
    private let ttl: TimeInterval = 86_400 // 24 heures
    
    // MARK: - Public Methods
    
    /// Charge les horaires depuis le cache CloudKit si disponibles et frais
    /// - Parameter placeKey: Identifiant unique du lieu (format: "nom|latitude,longitude")
    /// - Returns: Les horaires en cache ou nil si pas disponible/expiré
    func loadHours(placeKey: String) async -> String? {
        do {
            let predicate = NSPredicate(format: "placeKey == %@", placeKey)
            let query = CKQuery(recordType: recordType, predicate: predicate)
            
            // Timeout court pour ne pas bloquer l'utilisateur
            let (matchResults, _) = try await withTimeout(seconds: 2) {
                try await self.database.records(matching: query, desiredKeys: ["hours", "updatedAt"])
            }
            
            // Récupérer le premier résultat
            guard let firstMatch = matchResults.first,
                  case .success(let record) = firstMatch.1 else {
                return nil
            }
            
            // Vérifier la fraîcheur du cache
            guard let updatedAt = record["updatedAt"] as? Date,
                  Date().timeIntervalSince(updatedAt) < ttl else {
                print("📦 Cache CloudKit expiré pour: \(placeKey)")
                return nil
            }
            
            let hours = record["hours"] as? String
            if hours != nil {
                print("✅ Horaires chargés depuis CloudKit (cache partagé): \(placeKey)")
            }
            return hours
            
        } catch {
            // Erreur silencieuse: pas de CloudKit disponible, on passera par Google
            print("⚠️ CloudKit cache non disponible (normal si pas d'iCloud): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Sauvegarde les horaires dans le cache CloudKit partagé
    /// - Parameters:
    ///   - placeKey: Identifiant unique du lieu
    ///   - hours: Horaires à sauvegarder
    func saveHours(placeKey: String, hours: String) async {
        do {
            let record = CKRecord(recordType: recordType)
            record["placeKey"] = placeKey as CKRecordValue
            record["hours"] = hours as CKRecordValue
            record["updatedAt"] = Date() as CKRecordValue
            
            _ = try await database.save(record)
            print("💾 Horaires sauvegardés dans CloudKit (cache partagé): \(placeKey)")
            
        } catch {
            // Erreur silencieuse: pas critique si la sauvegarde échoue
            print("⚠️ Impossible de sauvegarder dans CloudKit: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helpers
    
    /// Exécute une opération async avec timeout
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw CancellationError()
            }
            
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

