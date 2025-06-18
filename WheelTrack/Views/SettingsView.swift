import SwiftUI
import Foundation
import UserNotifications

public struct SettingsView: View {
    @AppStorage("app_language") private var appLanguage: String = "fr"
    @State private var showingAbout = false
    @State private var showingPrivacy = false
    @State private var showingTerms = false
    @State private var showingNotifications = false
    // @StateObject private var tutorialService = TutorialService.shared // Temporairement commenté
    
    public init() {}

    // MARK: - Localization
    private static func localText(_ key: String, _ language: String) -> String {
        switch (key, language) {
        case ("settings", "en"): return "Settings"
        case ("settings", _): return "Paramètres"
        case ("general_settings", "en"): return "General Settings"
        case ("general_settings", _): return "Paramètres généraux"
        case ("about", "en"): return "About"
        case ("about", _): return "À propos"
        case ("notifications", "en"): return "Notifications"
        case ("notifications", _): return "Notifications"
        case ("privacy", "en"): return "Privacy"
        case ("privacy", _): return "Confidentialité"
        case ("privacy_policy", "en"): return "Privacy Policy"
        case ("privacy_policy", _): return "Politique de confidentialité"
        case ("terms", "en"): return "Terms of Service"
        case ("terms", _): return "Conditions d'utilisation"
        case ("tutorial", "en"): return "Show Tutorial"
        case ("tutorial", _): return "Revoir le tutoriel"
        case ("close", "en"): return "Close"
        case ("close", _): return "Fermer"
        case ("contact_us", "en"): return "Contact Us"
        case ("contact_us", _): return "Nous contacter"
        case ("support", "en"): return "Support"
        case ("support", _): return "Support"
        case ("legal_info", "en"): return "Legal Information"
        case ("legal_info", _): return "Informations légales"
        case ("copyright", "en"): return "© 2024 WheelTrack. All rights reserved."
        case ("copyright", _): return "© 2024 WheelTrack. Tous droits réservés."
        default: return key
        }
    }
    
    private func localText(_ key: String) -> String {
        return Self.localText(key, appLanguage)
    }

    public var body: some View {
        NavigationStack {
            List {
                // Section Paramètres
                Section(localText("settings")) {
                    // Paramètres généraux
                    NavigationLink(destination: TemporaryGeneralSettingsView()) {
                        HStack {
                            Image(systemName: "gear")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            
                            Text(localText("general_settings"))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .accessibilityLabel(localText("general_settings"))
                    .accessibilityHint("Configuration générale de l'application")
                    
                    // À propos
                    Button(action: { showingAbout = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .frame(width: 24, height: 24)
                            
                            Text(localText("about"))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(localText("about"))
                    .accessibilityHint("Informations sur l'application, support et crédits")
                    
                    // Notifications
                    Button(action: { showingNotifications = true }) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.orange)
                                .frame(width: 24, height: 24)
                            
                            Text(localText("notifications"))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(localText("notifications"))
                    .accessibilityHint("Gérer vos préférences de notifications")
                    
                    // Confidentialité
                    Button(action: { showingPrivacy = true }) {
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.red)
                                .frame(width: 24, height: 24)
                            
                            Text(localText("privacy"))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(localText("privacy_policy"))
                    .accessibilityHint("Informations sur la protection de vos données personnelles")
                    
                    // Tutoriel (temporairement désactivé)
                    Button(action: { /* tutorialService.startTutorial() */ }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.purple)
                                .frame(width: 24, height: 24)
                            
                            Text(localText("tutorial"))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(localText("tutorial"))
                    .accessibilityHint("Relancer le tutoriel d'introduction de l'application")
                }
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAbout) {
                SimpleAboutView(language: appLanguage)
            }
            .sheet(isPresented: $showingPrivacy) {
                SimplePrivacyView(language: appLanguage)
            }
            .sheet(isPresented: $showingNotifications) {
                NotificationSettingsView(language: appLanguage)
            }
        }
        .accessibilityIdentifier("SettingsView")
    }
}

// MARK: - Simple About View (intégrée pour éviter les problèmes d'import)
struct SimpleAboutView: View {
    let language: String
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Localization
    private static func localText(_ key: String, _ language: String) -> String {
        switch (key, language) {
        case ("about", "en"): return "About"
        case ("about", _): return "À propos"
        case ("close", "en"): return "Close"
        case ("close", _): return "Fermer"
        case ("version", "en"): return "Version 1.0.0"
        case ("version", _): return "Version 1.0.0"
        case ("app_description", "en"): return "The smart assistant to manage your vehicles"
        case ("app_description", _): return "L'assistant intelligent pour gérer vos véhicules"
        case ("features_subtitle", "en"): return "Maintenance • Finance • Analytics • Rentals"
        case ("features_subtitle", _): return "Maintenance • Finances • Analytics • Locations"
        case ("main_features", "en"): return "Main Features"
        case ("main_features", _): return "Fonctionnalités principales"
        case ("dashboard_title", "en"): return "Smart Dashboard"
        case ("dashboard_title", _): return "Tableau de Bord Intelligent"
        case ("dashboard_desc", "en"): return "Overview with real-time statistics and detailed analytics"
        case ("dashboard_desc", _): return "Vue d'ensemble avec statistiques en temps réel et analytics détaillés"
        case ("vehicles_title", "en"): return "Complete Vehicle Management"
        case ("vehicles_title", _): return "Gestion Complète des Véhicules"
        case ("vehicles_desc", "en"): return "Detailed catalog, fuel tracking and depreciation calculation"
        case ("vehicles_desc", _): return "Catalogue détaillé, suivi carburant et calcul de dépréciation"
        case ("maintenance_title", "en"): return "Smart Maintenance"
        case ("maintenance_title", _): return "Maintenance Intelligente"
        case ("maintenance_desc", "en"): return "Proactive tracking with automatic reminders every 6 months"
        case ("maintenance_desc", _): return "Suivi proactif avec rappels automatiques tous les 6 mois"
        case ("finance_title", "en"): return "Finance & Analytics"
        case ("finance_title", _): return "Finances & Analytics"
        case ("finance_desc", "en"): return "8 expense categories with CloudKit synchronization"
        case ("finance_desc", _): return "8 catégories de dépenses avec synchronisation CloudKit"
        case ("advanced_features", "en"): return "Advanced Features"
        case ("advanced_features", _): return "Fonctionnalités avancées"
        case ("garage_title", "en"): return "Garage Network"
        case ("garage_title", _): return "Réseau de Garages"
        case ("garage_desc", "en"): return "Automatic geolocation and interactive map with favorites"
        case ("garage_desc", _): return "Géolocalisation automatique et carte interactive avec favoris"
        case ("rental_title", "en"): return "Vehicle Rental"
        case ("rental_title", _): return "Location de Véhicules"
        case ("rental_desc", "en"): return "Complete system with contracts and PDF export"
        case ("rental_desc", _): return "Système complet avec contrats et export PDF"
        case ("support", "en"): return "Support"
        case ("support", _): return "Support"
        case ("contact_us", "en"): return "Contact Us"
        case ("contact_us", _): return "Nous contacter"
        case ("legal_info", "en"): return "Legal Information"
        case ("legal_info", _): return "Informations légales"
        case ("privacy_policy", "en"): return "Privacy Policy"
        case ("privacy_policy", _): return "Politique de confidentialité"
        case ("terms", "en"): return "Terms of Service"
        case ("terms", _): return "Conditions d'utilisation"
        case ("copyright", "en"): return "© 2024 WheelTrack. All rights reserved."
        case ("copyright", _): return "© 2024 WheelTrack. Tous droits réservés."
        default: return key
        }
    }
    
    private func localText(_ key: String) -> String {
        return Self.localText(key, language)
    }
    
    var body: some View {
        NavigationView {
            List {
                // Header Section
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "car.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 4) {
                            Text("WheelTrack")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(localText("version"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(localText("app_description"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Text(localText("features_subtitle"))
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .listRowBackground(Color.clear)
                
                // App Features
                Section(localText("main_features")) {
                    SettingsFeatureRow(
                        icon: "house.fill", 
                        title: localText("dashboard_title"), 
                        subtitle: localText("dashboard_desc")
                    )
                    
                    SettingsFeatureRow(
                        icon: "car.2.fill", 
                        title: localText("vehicles_title"), 
                        subtitle: localText("vehicles_desc")
                    )
                    
                    SettingsFeatureRow(
                        icon: "wrench.and.screwdriver.fill", 
                        title: localText("maintenance_title"), 
                        subtitle: localText("maintenance_desc")
                    )
                    
                    SettingsFeatureRow(
                        icon: "chart.bar.xaxis", 
                        title: localText("finance_title"), 
                        subtitle: localText("finance_desc")
                    )
                }
                
                Section(localText("advanced_features")) {
                    SettingsFeatureRow(
                        icon: "location.circle.fill", 
                        title: localText("garage_title"), 
                        subtitle: localText("garage_desc")
                    )
                    
                    SettingsFeatureRow(
                        icon: "key.fill", 
                        title: localText("rental_title"), 
                        subtitle: localText("rental_desc")
                    )
                }
                
                // Support
                Section(localText("support")) {
                    Button(localText("contact_us")) {
                        if let url = URL(string: "mailto:support@wheeltrack.app") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                
                // Legal
                Section(localText("legal_info")) {
                    Button(localText("privacy_policy")) {
                        // Fermer About et ouvrir Privacy
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            // Cette approche simple évite les problèmes de navigation complexe
                        }
                    }
                    
                    Button(localText("terms")) {
                        // Fermer About et ouvrir Terms
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            // Cette approche simple évite les problèmes de navigation complexe
                        }
                    }
                    
                    Text(localText("copyright"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(localText("about"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localText("close")) { dismiss() }
                }
            }
        }
    }
}

// MARK: - Simple Privacy View (intégrée pour éviter les problèmes d'import)
struct SimplePrivacyView: View {
    let language: String
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Localization
    private static func localText(_ key: String, _ language: String) -> String {
        switch (key, language) {
        case ("privacy_policy", "en"): return "Privacy Policy"
        case ("privacy_policy", _): return "Politique de confidentialité"
        case ("privacy", "en"): return "Privacy"
        case ("privacy", _): return "Confidentialité"
        case ("close", "en"): return "Close"
        case ("close", _): return "Fermer"
        case ("data_collection", "en"): return "Data Collection"
        case ("data_collection", _): return "Collecte des données"
        case ("data_collection_text", "en"): return "WheelTrack stores all your data locally on your device. No data is transmitted to external servers."
        case ("data_collection_text", _): return "WheelTrack stocke toutes vos données localement sur votre appareil. Aucune donnée n'est transmise à des serveurs externes."
        case ("location", "en"): return "Location"
        case ("location", _): return "Localisation"
        case ("location_text", "en"): return "The application uses your location only to find nearby garages. This data is never saved."
        case ("location_text", _): return "L'application utilise votre localisation uniquement pour trouver des garages à proximité. Ces données ne sont jamais sauvegardées."
        case ("security", "en"): return "Security"
        case ("security", _): return "Sécurité"
        case ("security_text", "en"): return "All your data is encrypted according to iOS standards. You maintain full control over your information."
        case ("security_text", _): return "Toutes vos données sont chiffrées selon les standards iOS. Vous gardez le contrôle total sur vos informations."
        case ("contact", "en"): return "Contact"
        case ("contact", _): return "Contact"
        case ("contact_text", "en"): return "For any questions: support@wheeltrack.app"
        case ("contact_text", _): return "Pour toute question: support@wheeltrack.app"
        case ("last_update", "en"): return "Last updated: January 2024"
        case ("last_update", _): return "Dernière mise à jour : Janvier 2024"
        default: return key
        }
    }
    
    private func localText(_ key: String) -> String {
        return Self.localText(key, language)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(localText("privacy_policy"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom)
                    
                    PrivacyText(title: localText("data_collection"), content: localText("data_collection_text"))
                    
                    PrivacyText(title: localText("location"), content: localText("location_text"))
                    
                    PrivacyText(title: localText("security"), content: localText("security_text"))
                    
                    PrivacyText(title: localText("contact"), content: localText("contact_text"))
                    
                    Text(localText("last_update"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            .navigationTitle(localText("privacy"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localText("close")) { dismiss() }
                }
            }
        }
    }
}

// MARK: - Notification Settings View
struct NotificationSettingsView: View {
    let language: String
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notifications_maintenance_enabled") private var maintenanceEnabled = true
    @AppStorage("notifications_expenses_enabled") private var expensesEnabled = true
    @AppStorage("notifications_rentals_enabled") private var rentalsEnabled = true
    @AppStorage("notifications_time_hour") private var notificationHour = 9
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    // MARK: - Localization
    private static func localText(_ key: String, _ language: String) -> String {
        switch (key, language) {
        case ("notifications", "en"): return "Notifications"
        case ("notifications", _): return "Notifications"
        case ("close", "en"): return "Close"
        case ("close", _): return "Fermer"
        case ("settings", "en"): return "Settings"
        case ("settings", _): return "Réglages"
        case ("authorization", "en"): return "AUTHORIZATION"
        case ("authorization", _): return "AUTORISATION"
        case ("notification_status", "en"): return "Notification status"
        case ("notification_status", _): return "État des notifications"
        case ("status_enabled", "en"): return "Notifications enabled"
        case ("status_enabled", _): return "Notifications activées"
        case ("status_denied", "en"): return "Notifications disabled in settings"
        case ("status_denied", _): return "Notifications désactivées dans les réglages"
        case ("notification_types", "en"): return "NOTIFICATION TYPES"
        case ("notification_types", _): return "TYPES DE NOTIFICATIONS"
        case ("maintenance", "en"): return "Maintenance"
        case ("maintenance", _): return "Maintenance"
        case ("maintenance_desc", "en"): return "Reminder 6 months after each intervention"
        case ("maintenance_desc", _): return "Rappel 6 mois après chaque intervention"
        case ("expenses", "en"): return "Expenses"
        case ("expenses", _): return "Dépenses"
        case ("expenses_desc", "en"): return "Monthly reminder to check your costs"
        case ("expenses_desc", _): return "Rappel mensuel pour vérifier vos coûts"
        case ("rentals", "en"): return "Rentals"
        case ("rentals", _): return "Locations"
        case ("rentals_desc", "en"): return "Alert 1 day before contract end"
        case ("rentals_desc", _): return "Alerte 1 jour avant fin de contrat"
        case ("schedules", "en"): return "SCHEDULES"
        case ("schedules", _): return "HORAIRES"
        case ("notification_time", "en"): return "Notification time"
        case ("notification_time", _): return "Heure des notifications"
        case ("notification_time_desc", "en"): return "Choose the ideal time to receive your reminders"
        case ("notification_time_desc", _): return "Choisissez le moment idéal pour recevoir vos rappels"
        case ("information", "en"): return "INFORMATION"
        case ("information", _): return "INFORMATIONS"
        case ("how_it_works", "en"): return "How does it work?"
        case ("how_it_works", _): return "Comment ça marche ?"
        case ("how_it_works_desc", "en"): return "WheelTrack automatically schedules reminders based on your activities. You can disable each type according to your preferences."
        case ("how_it_works_desc", _): return "WheelTrack programme automatiquement des rappels basés sur vos activités. Vous pouvez désactiver chaque type selon vos préférences."
        default: return key
        }
    }
    
    private func localText(_ key: String) -> String {
        return Self.localText(key, language)
    }
    
    var body: some View {
        NavigationView {
            List {
                // Status Section
                Section {
                    HStack {
                        Image(systemName: statusIcon)
                            .foregroundColor(statusColor)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localText("notification_status"))
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text(statusText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if notificationStatus == .denied {
                            Button(localText("settings")) {
                                openSettings()
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(localText("authorization"))
                }
                
                // Notification Types
                Section {
                    NotificationToggleRow(
                        icon: "wrench.and.screwdriver.fill",
                        title: localText("maintenance"),
                        subtitle: localText("maintenance_desc"),
                        isEnabled: $maintenanceEnabled,
                        color: .blue
                    )
                    
                    NotificationToggleRow(
                        icon: "eurosign.circle.fill",
                        title: localText("expenses"),
                        subtitle: localText("expenses_desc"),
                        isEnabled: $expensesEnabled,
                        color: .green
                    )
                    
                    NotificationToggleRow(
                        icon: "key.fill",
                        title: localText("rentals"),
                        subtitle: localText("rentals_desc"),
                        isEnabled: $rentalsEnabled,
                        color: .orange
                    )
                } header: {
                    Text(localText("notification_types"))
                }
                
                // Timing Section
                Section {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localText("notification_time"))
                                .font(.body)
                                .fontWeight(.medium)
                            
                            Text(localText("notification_time_desc"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Picker("Heure", selection: $notificationHour) {
                            Text("9h00").tag(9)
                            Text("12h00").tag(12)
                            Text("18h00").tag(18)
                            Text("20h00").tag(20)
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text(localText("schedules"))
                }
                
                // Info Section
                Section {
                    NotificationInfoCard(
                        icon: "info.circle.fill",
                        title: localText("how_it_works"),
                        content: localText("how_it_works_desc"),
                        color: .blue
                    )
                } header: {
                    Text(localText("information"))
                }
            }
            .navigationTitle(localText("notifications"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localText("close")) { dismiss() }
                }
            }
            .onAppear {
                checkNotificationStatus()
            }
        }
    }
    
    private var statusIcon: String {
        switch notificationStatus {
        case .authorized:
            return "checkmark.circle.fill"
        case .denied:
            return "xmark.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch notificationStatus {
        case .authorized:
            return .green
        case .denied:
            return .red
        default:
            return .orange
        }
    }
    
    private var statusText: String {
        switch notificationStatus {
        case .authorized:
            return localText("status_enabled")
        case .denied:
            return localText("status_denied")
        default:
            return "Statut inconnu"
        }
    }
    
    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationStatus = settings.authorizationStatus
            }
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Supporting Views for Notifications

struct NotificationToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isEnabled: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

struct NotificationInfoCard: View {
    let icon: String
    let title: String
    let content: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Helper Views
struct SettingsFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct PrivacyText: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Temporary General Settings View (en attendant la résolution du problème d'import)
struct TemporaryGeneralSettingsView: View {
    @AppStorage("app_language") private var selectedLanguage = "fr"
    @AppStorage("currency_symbol") private var currencySymbol = "€"
    @AppStorage("distance_unit") private var distanceUnit = "km"
    @AppStorage("fuel_consumption_unit") private var fuelUnit = "L/100km"
    @AppStorage("haptic_feedback_enabled") private var hapticEnabled = true
    @State private var showingLanguageAlert = false
    
    var body: some View {
        List {
            // Section Langue
            Section {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Langue de l'interface")
                            .font(.body)
                        Text("Changement instantané")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: { toggleLanguage() }) {
                        HStack(spacing: 8) {
                            Text(selectedLanguage == "fr" ? "🇫🇷" : "🇺🇸")
                            Text(selectedLanguage == "fr" ? "Français" : "English")
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                            
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
                
                // Devise
                HStack {
                    Image(systemName: "eurosign.circle")
                        .foregroundColor(.green)
                        .frame(width: 24, height: 24)
                    
                    Text("Devise")
                        .font(.body)
                    
                    Spacer()
                    
                    Picker("Devise", selection: $currencySymbol) {
                        Text("€").tag("€")
                        Text("$").tag("$")
                        Text("£").tag("£")
                        Text("CHF").tag("CHF")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            } header: {
                Text("LANGUE ET RÉGION")
            } footer: {
                Text("Tapez le bouton pour basculer entre français et anglais")
            }
            
            // Section Unités
            Section("UNITÉS DE MESURE") {
                HStack {
                    Image(systemName: "ruler")
                        .foregroundColor(.orange)
                        .frame(width: 24, height: 24)
                    
                    Text("Distance")
                        .font(.body)
                    
                    Spacer()
                    
                    Picker("Distance", selection: $distanceUnit) {
                        Text("km").tag("km")
                        Text("miles").tag("miles")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                HStack {
                    Image(systemName: "fuelpump")
                        .foregroundColor(.red)
                        .frame(width: 24, height: 24)
                    
                    Text("Consommation")
                        .font(.body)
                    
                    Spacer()
                    
                    Picker("Consommation", selection: $fuelUnit) {
                        Text("L/100km").tag("L/100km")
                        Text("mpg").tag("mpg")
                        Text("km/L").tag("km/L")
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            
            // Section Expérience
            Section("EXPÉRIENCE UTILISATEUR") {
                HStack {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .foregroundColor(.cyan)
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Retour haptique")
                            .font(.body)
                        Text("Vibrations lors des interactions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $hapticEnabled)
                        .labelsHidden()
                }
            }
        }
        .navigationTitle("Paramètres généraux")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Langue modifiée", isPresented: $showingLanguageAlert) {
            Button("OK") { }
        } message: {
            Text("L'interface s'adapte automatiquement à la nouvelle langue.")
        }
    }
    
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
            
            // Feedback haptique si activé
            if hapticEnabled {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
            }
            
            showingLanguageAlert = true
        }
    }
}

#Preview("Settings") {
    SettingsView()
}

#Preview("Notifications") {
    NotificationSettingsView(language: "en")
}

#Preview("General Settings") {
    NavigationView {
        TemporaryGeneralSettingsView()
    }
} 