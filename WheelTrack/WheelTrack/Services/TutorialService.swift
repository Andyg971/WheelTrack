import SwiftUI

/// Service pour gérer l'affichage du tutoriel de première utilisation
class TutorialService: ObservableObject {
    
    static let shared = TutorialService()
    
    // MARK: - Published Properties
    
    /// Indique si le tutoriel doit être affiché
    @Published var shouldShowTutorial: Bool = false
    
    // MARK: - Private Properties
    
    /// Stockage permanent pour savoir si l'utilisateur a déjà vu le tutoriel
    @AppStorage("has_seen_tutorial") private var hasSeenTutorial: Bool = false
    
    /// Version du tutoriel (pour pouvoir forcer l'affichage si on met à jour le tutoriel)
    @AppStorage("tutorial_version") private var tutorialVersion: Int = 0
    
    /// Version actuelle du tutoriel
    private let currentTutorialVersion = 1
    
    // MARK: - Initializer
    
    private init() {
        checkIfShouldShowTutorial()
    }
    
    // MARK: - Public Methods
    
    /// Démarre le tutoriel
    func startTutorial() {
        shouldShowTutorial = true
    }
    
    /// Termine le tutoriel et marque l'utilisateur comme ayant vu le tutoriel
    func completeTutorial() {
        hasSeenTutorial = true
        tutorialVersion = currentTutorialVersion
        shouldShowTutorial = false
    }
    
    /// Ignore le tutoriel (bouton "Passer")
    func skipTutorial() {
        completeTutorial()
    }
    
    /// Force l'affichage du tutoriel (pour les tests ou nouvelles versions)
    func resetTutorial() {
        hasSeenTutorial = false
        tutorialVersion = 0
        checkIfShouldShowTutorial()
    }
    
    // MARK: - Private Methods
    
    /// Vérifie si le tutoriel doit être affiché
    private func checkIfShouldShowTutorial() {
        // Afficher le tutoriel si :
        // 1. L'utilisateur ne l'a jamais vu OU
        // 2. La version du tutoriel a changé
        shouldShowTutorial = !hasSeenTutorial || tutorialVersion < currentTutorialVersion
    }
} 