import SwiftUI

/// Vue principale du tutoriel d'onboarding
struct TutorialView: View {
    
    // MARK: - Properties
    
    /// Callback appelé quand le tutoriel se termine
    let onComplete: () -> Void
    
    /// Pages du tutoriel
    private let pages = TutorialPage.pages
    
    /// Index de la page courante
    @State private var currentPageIndex = 0
    
    /// Service de localisation
    @StateObject private var localizationService = LocalizationService.shared
    
    /// Feedback haptique
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Contenu principal
            TabView(selection: $currentPageIndex) {
                ForEach(pages.indices, id: \.self) { index in
                    TutorialPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.5), value: currentPageIndex)
            
            // Overlay avec contrôles
            VStack {
                // Header avec bouton Skip
                HStack {
                    Spacer()
                    
                    Button(action: skipTutorial) {
                        Text(localizationService.text(CommonTranslations.tutorialSkip.0, CommonTranslations.tutorialSkip.1))
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    .accessibilityLabel(localizationService.text(CommonTranslations.tutorialSkip.0, CommonTranslations.tutorialSkip.1))
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
                
                Spacer()
                
                // Footer avec indicateurs et boutons
                VStack(spacing: 25) {
                    // Indicateurs de page
                    HStack(spacing: 12) {
                        ForEach(pages.indices, id: \.self) { index in
                            Circle()
                                .fill(index == currentPageIndex ? Color.white : Color.white.opacity(0.4))
                                .frame(width: index == currentPageIndex ? 12 : 8, height: index == currentPageIndex ? 12 : 8)
                                .scaleEffect(index == currentPageIndex ? 1.2 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentPageIndex)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Boutons de navigation
                    HStack(spacing: 20) {
                        // Bouton Précédent
                        if currentPageIndex > 0 {
                            Button(action: previousPage) {
                                HStack(spacing: 8) {
                                    Image(systemName: "chevron.left")
                                        .font(.body.weight(.medium))
                                    Text(localizationService.text(CommonTranslations.tutorialPrevious.0, CommonTranslations.tutorialPrevious.1))
                                        .font(.body.weight(.medium))
                                }
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.2))
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            .accessibilityLabel(localizationService.text(CommonTranslations.tutorialPrevious.0, CommonTranslations.tutorialPrevious.1))
                        } else {
                            // Spacer invisible pour maintenir l'alignement
                            Spacer()
                                .frame(width: 100)
                        }
                        
                        Spacer()
                        
                        // Bouton Suivant/Commencer
                        Button(action: nextPageOrComplete) {
                            HStack(spacing: 8) {
                                Text(isLastPage ? 
                                     localizationService.text(CommonTranslations.tutorialStart.0, CommonTranslations.tutorialStart.1) :
                                     localizationService.text(CommonTranslations.tutorialNext.0, CommonTranslations.tutorialNext.1)
                                )
                                .font(.body.weight(.semibold))
                                
                                if !isLastPage {
                                    Image(systemName: "chevron.right")
                                        .font(.body.weight(.medium))
                                }
                            }
                            .foregroundColor(isLastPage ? Color.white : Color.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(isLastPage ? Color.white.opacity(0.2) : Color.black.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white, lineWidth: isLastPage ? 2 : 1)
                                    )
                            )
                            .scaleEffect(isLastPage ? 1.05 : 1.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isLastPage)
                        }
                        .accessibilityLabel(isLastPage ? 
                                           localizationService.text(CommonTranslations.tutorialStart.0, CommonTranslations.tutorialStart.1) :
                                           localizationService.text(CommonTranslations.tutorialNext.0, CommonTranslations.tutorialNext.1)
                        )
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.bottom, 50)
            }
        }
        .statusBarHidden()
    }
    
    // MARK: - Computed Properties
    
    /// Indique si on est sur la dernière page
    private var isLastPage: Bool {
        currentPageIndex == pages.count - 1
    }
    
    // MARK: - Actions
    
    /// Passe à la page suivante ou termine le tutoriel
    private func nextPageOrComplete() {
        impactFeedback.impactOccurred()
        
        if isLastPage {
            // Terminer le tutoriel
            onComplete()
        } else {
            // Page suivante
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPageIndex += 1
            }
        }
    }
    
    /// Revient à la page précédente
    private func previousPage() {
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.5)) {
            currentPageIndex = max(0, currentPageIndex - 1)
        }
    }
    
    /// Ignore le tutoriel
    private func skipTutorial() {
        impactFeedback.impactOccurred()
        onComplete()
    }
}

// MARK: - Preview

#Preview {
    TutorialView {
        print("Tutoriel terminé")
    }
} 