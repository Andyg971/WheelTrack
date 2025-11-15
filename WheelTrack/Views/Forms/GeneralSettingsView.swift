import SwiftUI
import Foundation

/// Vue des paramètres généraux - Bilingual FR/EN
public struct GeneralSettingsView: View {
    
    // MARK: - App Storage pour persister les préférences
    @AppStorage("app_language") private var selectedLanguage = "fr"
    @AppStorage("currency_symbol") private var currencySymbol = "€"
    @AppStorage("distance_unit") private var distanceUnit = "km"
    @AppStorage("fuel_consumption_unit") private var fuelUnit = "L/100km"
    @AppStorage("haptic_feedback_enabled") private var hapticEnabled = true
    @AppStorage("icloud_sync_preferences") private var iCloudSyncEnabled = false
    
    // MARK: - CloudKit Integration (optionnel)
    @ObservedObject private var cloudKitService = CloudKitPreferencesService.shared
    
    // MARK: - State pour l'interface
    @State private var showingLanguageAlert = false
    
    // MARK: - Langues disponibles (seulement FR/EN)
    private let availableLanguages = [
        ("fr", "Français", "🇫🇷"),
        ("en", "English", "🇺🇸")
    ]
    
    // MARK: - Devises par région
    private let currencies = ["€", "$", "£", "CHF"]
    
    // MARK: - Unités selon région
    private let distanceUnits = ["km", "miles"]
    private let fuelUnits = ["L/100km", "mpg", "km/L"]
    
    public init() {}
    
    public var body: some View {
        List {
            // MARK: - Section Langue et Région
            Section {
                // Sélecteur de langue simplifié
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentLanguageText("Langue de l'interface", "Interface Language"))
                            .font(.body)
                        Text(currentLanguageText("Changement instantané", "Instant change"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Toggle simple FR/EN
                    Button(action: {
                        toggleLanguage()
                    }) {
                        HStack(spacing: 8) {
                            if let current = availableLanguages.first(where: { $0.0 == selectedLanguage }) {
                                Text(current.2) // Flag
                                Text(current.1) // Name
                                    .foregroundColor(.primary)
                                    .fontWeight(.medium)
                            }
                            
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                // Devise adaptée à la langue
                HStack {
                    Image(systemName: "eurosign.circle")
                        .foregroundColor(.green)
                        .frame(width: 24, height: 24)
                    
                    Text(currentLanguageText("Devise", "Currency"))
                        .font(.body)
                    
                    Spacer()
                    
                    Picker(currentLanguageText("Devise", "Currency"), selection: $currencySymbol) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
            } header: {
                Text(currentLanguageText("LANGUE ET RÉGION", "LANGUAGE & REGION"))
            } footer: {
                Text(currentLanguageText("Tapez le bouton pour basculer entre français et anglais", "Tap the button to toggle between French and English"))
            }
            
            // MARK: - Section Unités
            Section(currentLanguageText("UNITÉS DE MESURE", "MEASUREMENT UNITS")) {
                // Unité de distance
                HStack {
                    Image(systemName: "ruler")
                        .foregroundColor(.orange)
                        .frame(width: 24, height: 24)
                    
                    Text(currentLanguageText("Distance", "Distance"))
                        .font(.body)
                    
                    Spacer()
                    
                    Picker(currentLanguageText("Distance", "Distance"), selection: $distanceUnit) {
                        ForEach(distanceUnits, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // Unité de consommation
                HStack {
                    Image(systemName: "fuelpump")
                        .foregroundColor(.red)
                        .frame(width: 24, height: 24)
                    
                    Text(currentLanguageText("Consommation", "Fuel Consumption"))
                        .font(.body)
                    
                    Spacer()
                    
                    Picker(currentLanguageText("Consommation", "Consumption"), selection: $fuelUnit) {
                        ForEach(fuelUnits, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            
            // MARK: - Section Expérience
            Section(currentLanguageText("EXPÉRIENCE UTILISATEUR", "USER EXPERIENCE")) {
                // Retour haptique
                HStack {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .foregroundColor(.cyan)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentLanguageText("Retour haptique", "Haptic Feedback"))
                            .font(.body)
                        Text(currentLanguageText("Vibrations lors des interactions", "Vibrations during interactions"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $hapticEnabled)
                        .labelsHidden()
                }
            }
            
            // MARK: - Section Synchronisation iCloud (Optionnelle)
            Section {
                // Toggle pour activer/désactiver la synchronisation
                HStack {
                    Image(systemName: "icloud.fill")
                        .foregroundColor(iCloudSyncEnabled ? .blue : .gray)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentLanguageText("Synchronisation iCloud", "iCloud Sync"))
                            .font(.body)
                        Text(currentLanguageText("Synchroniser sur tous vos appareils", "Sync across all your devices"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $iCloudSyncEnabled)
                        .labelsHidden()
                        .onChange(of: iCloudSyncEnabled) { _, newValue in
                            handleiCloudToggle(newValue)
                        }
                }
                
                // Status et boutons uniquement si activé
                if iCloudSyncEnabled {
                    HStack {
                        cloudKitService.syncStatusIndicator
                        
                        Spacer()
                        
                        Button(action: {
                            Task {
                                await cloudKitService.forceSyncNow()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.caption)
                                Text(currentLanguageText("Synchroniser", "Sync Now"))
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        }
                        .disabled(cloudKitService.syncStatus.isLoading)
                    }
                }
            } header: {
                Text(currentLanguageText("SYNCHRONISATION (OPTIONNELLE)", "SYNC (OPTIONAL)"))
            } footer: {
                if iCloudSyncEnabled {
                    Text(currentLanguageText("✅ Synchronisation activée. Vos préférences sont sauvegardées automatiquement sur iCloud.", "✅ Sync enabled. Your preferences are automatically saved to iCloud."))
                } else {
                    Text(currentLanguageText("💾 Mode local uniquement. Activez pour synchroniser vos préférences sur tous vos appareils.", "💾 Local mode only. Enable to sync your preferences across all devices."))
                }
            }
            
            // MARK: - Section Info
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(currentLanguageText("Les paramètres sont automatiquement sauvegardés.", "Settings are automatically saved."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(currentLanguageText("Le changement de langue met à jour cette vue instantanément.", "Language change updates this view instantly."))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // MARK: - Section Test (Debug)
            if true { // Peut être conditionné pour le développement
                Section(currentLanguageText("DÉVELOPPEMENT", "DEVELOPMENT")) {
                    NavigationLink(destination: LanguageTestView()) {
                        HStack {
                            Image(systemName: "testtube.2")
                                .foregroundColor(.purple)
                                .frame(width: 24, height: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(currentLanguageText("Tester la localisation", "Test Localization"))
                                    .font(.body)
                                Text(currentLanguageText("Vérifier les traductions", "Check translations"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .navigationTitle(currentLanguageText("Paramètres généraux", "General Settings"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(currentLanguageText("Langue modifiée", "Language Changed"), isPresented: $showingLanguageAlert) {
            Button(currentLanguageText("OK", "OK")) { }
        } message: {
            Text(currentLanguageText("L'interface s'adapte automatiquement à la nouvelle langue.", "Interface automatically adapts to the new language."))
        }
        .onChange(of: currencySymbol) {
            if iCloudSyncEnabled {
                Task {
                    await cloudKitService.syncPreferences()
                }
            }
        }
        .onChange(of: distanceUnit) {
            if iCloudSyncEnabled {
                Task {
                    await cloudKitService.syncPreferences()
                }
            }
        }
        .onChange(of: fuelUnit) {
            if iCloudSyncEnabled {
                Task {
                    await cloudKitService.syncPreferences()
                }
            }
        }
        .onChange(of: hapticEnabled) {
            if iCloudSyncEnabled {
                Task {
                    await cloudKitService.syncPreferences()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Retourne le texte dans la langue appropriée
    private func currentLanguageText(_ french: String, _ english: String) -> String {
        return selectedLanguage == "en" ? english : french
    }
    
    /// Toggle entre français et anglais
    private func toggleLanguage() {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedLanguage = selectedLanguage == "fr" ? "en" : "fr"
            
            // Adapter automatiquement les unités selon la langue
            if selectedLanguage == "en" {
                currencySymbol = "$"
                distanceUnit = "miles"
                fuelUnit = "mpg"
            } else {
                currencySymbol = "€"
                distanceUnit = "km"
                fuelUnit = "L/100km"
            }
            
            // Appliquer la langue à l'app
            applyLanguageToApp()
            
            // Feedback haptique si activé
            if hapticEnabled {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
            
            // Synchronisation CloudKit automatique seulement si activée
            if iCloudSyncEnabled {
                Task {
                    await cloudKitService.syncPreferences()
                }
            }
            
            showingLanguageAlert = true
        }
    }
    
    /// Gère l'activation/désactivation de la synchronisation iCloud
    private func handleiCloudToggle(_ isEnabled: Bool) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if isEnabled {
                // Première synchronisation lors de l'activation
                Task {
                    await cloudKitService.syncPreferences()
                }
            }
            
            // Feedback haptique
            if hapticEnabled {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }
    }
    
    /// Applique la langue à toute l'application
    private func applyLanguageToApp() {
        // Mettre à jour les préférences système
        UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Post notification pour informer l'app du changement
        NotificationCenter.default.post(name: .languageChanged, object: selectedLanguage)
    }
}

// MARK: - Notification Extension

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
    static let navigateToDashboard = Notification.Name("navigateToDashboard")
}

#Preview {
    NavigationView {
        GeneralSettingsView()
    }
} 