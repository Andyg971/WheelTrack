import SwiftUI

/// Vue de la Politique de Confidentialité / Privacy Policy
/// Contenu identique aux Conditions d'Utilisation comme demandé
struct PrivacyPolicyView: View {
    let language: String
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Localization
    private static func localText(_ key: String, _ language: String) -> String {
        switch (key, language) {
        case ("title", "en"): return "Privacy Policy"
        case ("title", _): return "Politique de Confidentialité"
        case ("close", "en"): return "Close"
        case ("close", _): return "Fermer"
        
        // Introduction
        case ("intro_title", "en"): return "1. Introduction"
        case ("intro_title", _): return "1. Introduction"
        case ("intro_text", "en"): return "Welcome to WheelTrack. By using our application, you accept this privacy policy. WheelTrack is a comprehensive vehicle management solution that helps you track maintenance, expenses, rentals, and more."
        case ("intro_text", _): return "Bienvenue sur WheelTrack. En utilisant notre application, vous acceptez cette politique de confidentialité. WheelTrack est une solution complète de gestion de véhicules qui vous aide à suivre l'entretien, les dépenses, les locations et bien plus encore."
        
        // Collecte des données
        case ("data_collection_title", "en"): return "2. Data Collection and Storage"
        case ("data_collection_title", _): return "2. Collecte et Stockage des Données"
        case ("data_collection_text", "en"): return "WheelTrack stores all your data locally on your device using iOS secure storage mechanisms. We use Apple's CloudKit for optional synchronization across your devices. No personal data is transmitted to external servers or third parties. Your data remains entirely under your control."
        case ("data_collection_text", _): return "WheelTrack stocke toutes vos données localement sur votre appareil en utilisant les mécanismes de stockage sécurisés d'iOS. Nous utilisons CloudKit d'Apple pour la synchronisation optionnelle entre vos appareils. Aucune donnée personnelle n'est transmise à des serveurs externes ou à des tiers. Vos données restent entièrement sous votre contrôle."
        
        // Utilisation des données
        case ("data_use_title", "en"): return "3. Data Usage"
        case ("data_use_title", _): return "3. Utilisation des Données"
        case ("data_use_text", "en"): return "The data you enter in WheelTrack is used exclusively to:\n\n• Manage your vehicles and their maintenance\n• Track expenses and generate financial reports\n• Create and manage rental contracts\n• Locate nearby garages using your location\n• Provide analytics and insights about your fleet\n\nNo data is used for advertising, profiling, or sold to third parties."
        case ("data_use_text", _): return "Les données que vous saisissez dans WheelTrack sont utilisées exclusivement pour :\n\n• Gérer vos véhicules et leur maintenance\n• Suivre les dépenses et générer des rapports financiers\n• Créer et gérer des contrats de location\n• Localiser les garages à proximité grâce à votre position\n• Fournir des analyses et des informations sur votre flotte\n\nAucune donnée n'est utilisée à des fins publicitaires, de profilage ou vendue à des tiers."
        
        // Localisation
        case ("location_title", "en"): return "4. Location Services"
        case ("location_title", _): return "4. Services de Localisation"
        case ("location_text", "en"): return "WheelTrack uses your location only when you actively use the garage search feature. Location data is:\n\n• Used only to find nearby garages\n• Never saved or stored\n• Never shared with third parties\n• Processed entirely on your device\n\nYou can disable location access at any time in iOS Settings."
        case ("location_text", _): return "WheelTrack utilise votre localisation uniquement lorsque vous utilisez activement la fonction de recherche de garages. Les données de localisation sont :\n\n• Utilisées uniquement pour trouver des garages à proximité\n• Jamais sauvegardées ni stockées\n• Jamais partagées avec des tiers\n• Traitées entièrement sur votre appareil\n\nVous pouvez désactiver l'accès à la localisation à tout moment dans les Réglages iOS."
        
        // Sécurité
        case ("security_title", "en"): return "5. Security"
        case ("security_title", _): return "5. Sécurité"
        case ("security_text", "en"): return "Your data security is our priority:\n\n• All data is encrypted using iOS standard encryption\n• CloudKit sync uses end-to-end encryption\n• No passwords are stored (we use Sign in with Apple)\n• Regular security updates are provided\n• You maintain full control over your data\n\nYou can delete all your data at any time by removing the app."
        case ("security_text", _): return "La sécurité de vos données est notre priorité :\n\n• Toutes les données sont chiffrées selon le standard de chiffrement iOS\n• La synchronisation CloudKit utilise un chiffrement de bout en bout\n• Aucun mot de passe n'est stocké (nous utilisons Se connecter avec Apple)\n• Des mises à jour de sécurité régulières sont fournies\n• Vous gardez le contrôle total sur vos données\n\nVous pouvez supprimer toutes vos données à tout moment en supprimant l'application."
        
        // Propriété des données
        case ("ownership_title", "en"): return "6. Data Ownership"
        case ("ownership_title", _): return "6. Propriété des Données"
        case ("ownership_text", "en"): return "You retain full ownership of all data you enter into WheelTrack. We claim no rights to your:\n\n• Vehicle information\n• Financial records\n• Maintenance history\n• Rental contracts\n• Photos and documents\n\nYou can export or delete your data at any time."
        case ("ownership_text", _): return "Vous conservez la propriété complète de toutes les données que vous saisissez dans WheelTrack. Nous ne revendiquons aucun droit sur vos :\n\n• Informations sur les véhicules\n• Dossiers financiers\n• Historique de maintenance\n• Contrats de location\n• Photos et documents\n\nVous pouvez exporter ou supprimer vos données à tout moment."
        
        // Achats et abonnements
        case ("purchase_title", "en"): return "7. Purchases and Subscriptions"
        case ("purchase_title", _): return "7. Achats et Abonnements"
        case ("purchase_text", "en"): return "WheelTrack offers premium features through in-app purchases:\n\n• All purchases are processed by Apple\n• We don't store your payment information\n• Subscriptions can be managed in iOS Settings\n• Premium features sync across your devices\n• Refunds are handled according to Apple's policies\n\nFree features remain available without any purchase."
        case ("purchase_text", _): return "WheelTrack propose des fonctionnalités premium via des achats intégrés :\n\n• Tous les achats sont traités par Apple\n• Nous ne stockons pas vos informations de paiement\n• Les abonnements peuvent être gérés dans les Réglages iOS\n• Les fonctionnalités premium se synchronisent entre vos appareils\n• Les remboursements sont gérés selon les politiques d'Apple\n\nLes fonctionnalités gratuites restent disponibles sans aucun achat."
        
        // Services tiers
        case ("third_party_title", "en"): return "8. Third-Party Services"
        case ("third_party_title", _): return "8. Services Tiers"
        case ("third_party_text", "en"): return "WheelTrack uses the following Apple services:\n\n• CloudKit for optional data synchronization\n• Sign in with Apple for authentication\n• In-App Purchase for premium features\n• Core Location for garage search\n\nThese services are governed by Apple's Privacy Policy. We don't use any other third-party analytics or tracking services."
        case ("third_party_text", _): return "WheelTrack utilise les services Apple suivants :\n\n• CloudKit pour la synchronisation optionnelle des données\n• Se connecter avec Apple pour l'authentification\n• Achats intégrés pour les fonctionnalités premium\n• Core Location pour la recherche de garages\n\nCes services sont régis par la Politique de Confidentialité d'Apple. Nous n'utilisons aucun autre service tiers d'analyse ou de suivi."
        
        // Vos droits
        case ("rights_title", "en"): return "9. Your Rights"
        case ("rights_title", _): return "9. Vos Droits"
        case ("rights_text", "en"): return "You have the right to:\n\n• Access all your data within the app\n• Export your data in PDF format\n• Delete specific records or all data\n• Disable location services\n• Opt out of CloudKit synchronization\n• Request support via email\n\nNo registration or account creation is required to use WheelTrack."
        case ("rights_text", _): return "Vous avez le droit de :\n\n• Accéder à toutes vos données dans l'application\n• Exporter vos données au format PDF\n• Supprimer des enregistrements spécifiques ou toutes les données\n• Désactiver les services de localisation\n• Refuser la synchronisation CloudKit\n• Demander de l'aide par email\n\nAucune inscription ni création de compte n'est requise pour utiliser WheelTrack."
        
        // Modifications
        case ("changes_title", "en"): return "10. Changes to Policy"
        case ("changes_title", _): return "10. Modifications de la Politique"
        case ("changes_text", "en"): return "We may update this privacy policy occasionally. Significant changes will be communicated through:\n\n• App update notifications\n• In-app announcements\n• Email notifications (if provided)\n\nContinued use of WheelTrack after changes constitutes acceptance of the new policy."
        case ("changes_text", _): return "Nous pouvons mettre à jour cette politique de confidentialité occasionnellement. Les modifications importantes seront communiquées via :\n\n• Notifications de mise à jour de l'application\n• Annonces dans l'application\n• Notifications par email (si fourni)\n\nL'utilisation continue de WheelTrack après les modifications constitue une acceptation de la nouvelle politique."
        
        // Contact
        case ("contact_title", "en"): return "11. Contact Us"
        case ("contact_title", _): return "11. Nous Contacter"
        case ("contact_text", "en"): return "For any questions, concerns, or requests regarding your privacy and data:\n\n📧 Email: support@wheeltrack.fr\n\nWe typically respond within 48 hours.\n\n"
        case ("contact_text", _): return "Pour toute question, préoccupation ou demande concernant votre confidentialité et vos données :\n\n📧 Email : support@wheeltrack.fr\n\nNous répondons généralement dans les 48 heures.\n\n"
        
        // Acceptation
        case ("acceptance_title", "en"): return "12. Acceptance"
        case ("acceptance_title", _): return "12. Acceptation"
        case ("acceptance_text", "en"): return "By using WheelTrack, you acknowledge that you have read, understood, and agree to this Privacy Policy."
        case ("acceptance_text", _): return "En utilisant WheelTrack, vous reconnaissez avoir lu, compris et accepté cette Politique de Confidentialité."
        
        case ("last_update", "en"): return "Last updated: January 2025"
        case ("last_update", _): return "Dernière mise à jour : Janvier 2025"
        case ("copyright", "en"): return "© 2025 WheelTrack. All rights reserved."
        case ("copyright", _): return "© 2025 WheelTrack. Tous droits réservés."
        
        default: return key
        }
    }
    
    private func localText(_ key: String) -> String {
        return Self.localText(key, language)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // En-tête
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localText("title"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(localText("last_update"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 8)
                    
                    // Contenu des sections
                    LegalSectionView(
                        title: localText("intro_title"),
                        content: localText("intro_text"),
                        icon: "doc.text",
                        color: .blue
                    )
                    
                    LegalSectionView(
                        title: localText("data_collection_title"),
                        content: localText("data_collection_text"),
                        icon: "externaldrive",
                        color: .green
                    )
                    
                    LegalSectionView(
                        title: localText("data_use_title"),
                        content: localText("data_use_text"),
                        icon: "chart.bar.fill",
                        color: .orange
                    )
                    
                    LegalSectionView(
                        title: localText("location_title"),
                        content: localText("location_text"),
                        icon: "location.fill",
                        color: .red
                    )
                    
                    LegalSectionView(
                        title: localText("security_title"),
                        content: localText("security_text"),
                        icon: "lock.shield.fill",
                        color: .purple
                    )
                    
                    LegalSectionView(
                        title: localText("ownership_title"),
                        content: localText("ownership_text"),
                        icon: "person.badge.key.fill",
                        color: .indigo
                    )
                    
                    LegalSectionView(
                        title: localText("purchase_title"),
                        content: localText("purchase_text"),
                        icon: "creditcard.fill",
                        color: .cyan
                    )
                    
                    LegalSectionView(
                        title: localText("third_party_title"),
                        content: localText("third_party_text"),
                        icon: "arrow.triangle.branch",
                        color: .teal
                    )
                    
                    LegalSectionView(
                        title: localText("rights_title"),
                        content: localText("rights_text"),
                        icon: "hand.raised.fill",
                        color: .mint
                    )
                    
                    LegalSectionView(
                        title: localText("changes_title"),
                        content: localText("changes_text"),
                        icon: "arrow.clockwise",
                        color: .brown
                    )
                    
                    LegalSectionView(
                        title: localText("contact_title"),
                        content: localText("contact_text"),
                        icon: "envelope.fill",
                        color: .pink
                    )
                    
                    LegalSectionView(
                        title: localText("acceptance_title"),
                        content: localText("acceptance_text"),
                        icon: "checkmark.seal.fill",
                        color: .green
                    )
                    
                    // Footer
                    VStack(spacing: 8) {
                        Divider()
                            .padding(.vertical, 8)
                        
                        Text(localText("copyright"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.top, 16)
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localText("close")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Legal Section Reusable View

struct LegalSectionView: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Titre avec icône
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 28)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            // Contenu
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview("Français") {
    PrivacyPolicyView(language: "fr")
}

#Preview("English") {
    PrivacyPolicyView(language: "en")
}

