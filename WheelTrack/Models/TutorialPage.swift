import Foundation

/// Modèle représentant une page du tutoriel
struct TutorialPage: Identifiable, Equatable {
    let id = UUID()
    let title: (String, String)           // Français, Anglais
    let subtitle: (String, String)        // Français, Anglais  
    let description: (String, String)     // Français, Anglais
    let systemImageName: String          // Icône SF Symbols
    let backgroundColor: String          // Couleur de fond
    let foregroundColor: String          // Couleur du texte
    
    /// Pages prédéfinies du tutoriel
    static let pages: [TutorialPage] = [
        TutorialPage(
            title: CommonTranslations.tutorialWelcomeTitle,
            subtitle: CommonTranslations.tutorialWelcomeSubtitle,
            description: CommonTranslations.tutorialWelcomeDescription,
            systemImageName: "hand.wave.fill",
            backgroundColor: "blue",
            foregroundColor: "white"
        ),
        TutorialPage(
            title: CommonTranslations.tutorialVehiclesTitle,
            subtitle: CommonTranslations.tutorialVehiclesSubtitle,
            description: CommonTranslations.tutorialVehiclesDescription,
            systemImageName: "car.fill",
            backgroundColor: "green",
            foregroundColor: "white"
        ),
        TutorialPage(
            title: CommonTranslations.tutorialFinancesTitle,
            subtitle: CommonTranslations.tutorialFinancesSubtitle,
            description: CommonTranslations.tutorialFinancesDescription,
            systemImageName: "chart.bar.fill",
            backgroundColor: "orange",
            foregroundColor: "white"
        ),
        TutorialPage(
            title: CommonTranslations.tutorialCloudTitle,
            subtitle: CommonTranslations.tutorialCloudSubtitle,
            description: CommonTranslations.tutorialCloudDescription,
            systemImageName: "icloud.fill",
            backgroundColor: "purple",
            foregroundColor: "white"
        )
    ]
} 