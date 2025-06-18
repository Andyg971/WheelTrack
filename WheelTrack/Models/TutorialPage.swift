import Foundation

/// Modèle représentant une page du tutoriel
struct TutorialPage: Identifiable, Equatable {
    let id: Int
    let title: (String, String)           // Français, Anglais
    let subtitle: (String, String)        // Français, Anglais
    let description: (String, String)     // Français, Anglais
    let systemImage: String
    let gradientColors: (String, String)  // Couleurs pour le dégradé
    
    // Implémentation manuelle de Equatable
    static func == (lhs: TutorialPage, rhs: TutorialPage) -> Bool {
        return lhs.id == rhs.id &&
               lhs.title.0 == rhs.title.0 &&
               lhs.title.1 == rhs.title.1 &&
               lhs.subtitle.0 == rhs.subtitle.0 &&
               lhs.subtitle.1 == rhs.subtitle.1 &&
               lhs.description.0 == rhs.description.0 &&
               lhs.description.1 == rhs.description.1 &&
               lhs.systemImage == rhs.systemImage &&
               lhs.gradientColors.0 == rhs.gradientColors.0 &&
               lhs.gradientColors.1 == rhs.gradientColors.1
    }
    
    /// Pages prédéfinies du tutoriel
    static let pages = [
        TutorialPage(
            id: 1,
            title: ("Bienvenue dans WheelTrack", "Welcome to WheelTrack"),
            subtitle: ("Votre compagnon pour la gestion automobile", "Your automotive management companion"),
            description: ("Gérez facilement vos véhicules, leurs dépenses et l'entretien en un seul endroit.", "Easily manage your vehicles, expenses and maintenance all in one place."),
            systemImage: "car.fill",
            gradientColors: ("blue", "purple")
        ),
        TutorialPage(
            id: 2,
            title: ("Gestion des véhicules", "Vehicle Management"),
            subtitle: ("Organisez votre garage", "Organize your garage"),
            description: ("Ajoutez vos véhicules, suivez leur kilométrage et gardez un historique complet.", "Add your vehicles, track mileage and keep a complete history."),
            systemImage: "plus.circle.fill",
            gradientColors: ("green", "blue")
        ),
        TutorialPage(
            id: 3,
            title: ("Suivi financier", "Financial Tracking"),
            subtitle: ("Contrôlez vos dépenses", "Control your expenses"),
            description: ("Enregistrez tous vos frais automobile et visualisez vos données avec des graphiques.", "Record all your automotive expenses and visualize your data with charts."),
            systemImage: "chart.bar.fill",
            gradientColors: ("orange", "red")
        ),
        TutorialPage(
            id: 4,
            title: ("Synchronisation CloudKit", "CloudKit Sync"),
            subtitle: ("Données synchronisées", "Synchronized data"),
            description: ("Vos données sont automatiquement sauvegardées et synchronisées sur tous vos appareils Apple.", "Your data is automatically backed up and synced across all your Apple devices."),
            systemImage: "icloud.fill",
            gradientColors: ("purple", "pink")
        )
    ]
} 