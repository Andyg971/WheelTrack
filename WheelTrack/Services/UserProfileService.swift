import Foundation
import Combine

class UserProfileService: ObservableObject {
    static let shared = UserProfileService()
    
    @Published var userProfile = UserProfile()
    
    private let persistenceFilename = "user_profile.json"
    
    private init() {
        loadUserProfile()
    }
    
    // MARK: - Persistance
    
    private func loadUserProfile() {
        if let loadedProfile = PersistenceService.load(UserProfile.self, from: persistenceFilename) {
            userProfile = loadedProfile
        } else {
            // Créer un profil par défaut si aucun n'existe
            userProfile = UserProfile()
            saveUserProfile()
        }
    }
    
    func saveUserProfile() {
        userProfile.lastUpdated = Date()
        PersistenceService.save(userProfile, to: persistenceFilename)
        objectWillChange.send()
    }
    
    // MARK: - Méthodes utilitaires
    
    func updateProfile(_ updatedProfile: UserProfile) {
        userProfile = updatedProfile
        saveUserProfile()
    }
    
    func resetProfile() {
        userProfile = UserProfile()
        saveUserProfile()
    }
    
    // MARK: - Validation et vérifications
    
    func getExpirationAlerts() -> [ProfileAlert] {
        var alerts: [ProfileAlert] = []
        
        // Vérification du permis de conduire
        if let daysUntil = userProfile.daysUntilLicenseExpiration {
            if daysUntil <= 0 {
                alerts.append(ProfileAlert(
                    type: .licenseExpired,
                    title: "Permis de conduire expiré",
                    message: "Votre permis de conduire a expiré",
                    priority: .high
                ))
            } else if daysUntil <= 30 {
                alerts.append(ProfileAlert(
                    type: .licenseExpiring,
                    title: "Permis bientôt expiré",
                    message: "Votre permis expire dans \(daysUntil) jour\(daysUntil > 1 ? "s" : "")",
                    priority: .medium
                ))
            }
        }
        
        // Vérification de l'assurance
        if let daysUntil = userProfile.daysUntilInsuranceExpiration {
            if daysUntil <= 0 {
                alerts.append(ProfileAlert(
                    type: .insuranceExpired,
                    title: "Assurance expirée",
                    message: "Votre assurance principale a expiré",
                    priority: .high
                ))
            } else if daysUntil <= 30 {
                alerts.append(ProfileAlert(
                    type: .insuranceExpiring,
                    title: "Assurance bientôt expirée", 
                    message: "Votre assurance expire dans \(daysUntil) jour\(daysUntil > 1 ? "s" : "")",
                    priority: .medium
                ))
            }
        }
        
        return alerts
    }
}

// MARK: - Structures d'alerte
struct ProfileAlert {
    let type: AlertType
    let title: String
    let message: String
    let priority: Priority
    
    enum AlertType {
        case licenseExpired
        case licenseExpiring
        case insuranceExpired
        case insuranceExpiring
    }
    
    enum Priority {
        case low, medium, high
    }
}