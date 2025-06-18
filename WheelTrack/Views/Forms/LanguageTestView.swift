import SwiftUI

/// Vue de test pour démontrer le système de localisation FR/EN
struct LanguageTestView: View {
    @ObservedObject private var localizationService = LocalizationService.shared
    
    var body: some View {
        NavigationStack {
            List {
                Section(L(("FONCTIONNALITÉS DE L'APP", "APP FEATURES"))) {
                    TestRow(
                        icon: "car.2.fill",
                        french: "Gestion Véhicules", 
                        english: "Vehicle Management"
                    )
                    
                    TestRow(
                        icon: "creditcard.fill",
                        french: "Suivi Financier", 
                        english: "Financial Tracking"
                    )
                    
                    TestRow(
                        icon: "wrench.and.screwdriver.fill",
                        french: "Maintenance Pro", 
                        english: "Pro Maintenance"
                    )
                    
                    TestRow(
                        icon: "building.2.fill",
                        french: "Réseau Garages", 
                        english: "Garage Network"
                    )
                    
                    TestRow(
                        icon: "key.radiowaves.forward.fill",
                        french: "Location Smart", 
                        english: "Smart Rentals"
                    )
                    
                    TestRow(
                        icon: "chart.line.uptrend.xyaxis",
                        french: "Dashboard Analytics", 
                        english: "Dashboard Analytics"
                    )
                }
                
                Section(L(("ACTIONS", "ACTIONS"))) {
                    TestRow(
                        icon: "plus.circle.fill",
                        french: "Ajouter", 
                        english: "Add"
                    )
                    
                    TestRow(
                        icon: "pencil.circle.fill",
                        french: "Modifier", 
                        english: "Edit"
                    )
                    
                    TestRow(
                        icon: "trash.circle.fill",
                        french: "Supprimer", 
                        english: "Delete"
                    )
                    
                    TestRow(
                        icon: "checkmark.circle.fill",
                        french: "Enregistrer", 
                        english: "Save"
                    )
                }
                
                Section(L(("INFOS SYSTÈME", "SYSTEM INFO"))) {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                        Text(L(("Langue actuelle", "Current Language")))
                        Spacer()
                        Text(localizationService.currentLanguage == "fr" ? "🇫🇷 Français" : "🇺🇸 English")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "textformat")
                            .foregroundColor(.green)
                        Text(L(("Total traductions", "Total Translations")))
                        Spacer()
                        Text("50+")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.shield")
                            .foregroundColor(.green)
                        Text(L(("Système fonctionnel", "System Working")))
                        Spacer()
                        Text("✅")
                    }
                }
                
                Section {
                    VStack(spacing: 8) {
                        Text(L(("Ce système de localisation permet de faire basculer instantanément toute l'application entre français et anglais.", "This localization system allows you to instantly switch the entire application between French and English.")))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Text(L(("Allez dans Réglages > Paramètres généraux pour changer la langue.", "Go to Settings > General Settings to change the language.")))
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(L(("Test Localisation", "Localization Test")))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TestRow: View {
    let icon: String
    let french: String
    let english: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(L((french, english)))
                    .font(.body)
                
                HStack(spacing: 4) {
                    Text("🇫🇷")
                        .font(.caption2)
                    Text(french)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("🇺🇸")
                        .font(.caption2)
                    Text(english)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
}

#Preview {
    LanguageTestView()
} 