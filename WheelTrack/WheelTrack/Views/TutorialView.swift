import SwiftUI

/// Vue principale du tutoriel d'onboarding
struct TutorialView: View {
    
    // MARK: - Properties
    
    @StateObject private var tutorialService = TutorialService.shared
    @State private var currentPageIndex = 0
    @State private var dragOffset: CGFloat = 0
    @Environment(\.dismiss) private var dismiss
    
    /// Pages du tutoriel
    private let pages = TutorialPage.pages
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Contenu principal avec TabView
                TabView(selection: $currentPageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        TutorialPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPageIndex)
                .onAppear {
                    // Feedback haptique au démarrage
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
                
                // Overlay avec contrôles
                VStack {
                    // Bouton Passer en haut à droite
                    HStack {
                        Spacer()
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            skipTutorial()
                        }) {
                            Text(LocalizationService.shared.currentLanguage == "fr" ? "Passer" : "Skip")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(.ultraThinMaterial, in: Capsule())
                        }
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 30)
                    
                    Spacer()
                    
                    // Contrôles du bas
                    VStack(spacing: 20) {
                        // Indicateur de page personnalisé
                        HStack(spacing: 12) {
                            ForEach(0..<pages.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPageIndex ? .white : .white.opacity(0.5))
                                    .frame(width: index == currentPageIndex ? 12 : 8, height: index == currentPageIndex ? 12 : 8)
                                    .scaleEffect(index == currentPageIndex ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPageIndex)
                            }
                        }
                        .padding(.bottom, 10)
                        
                        // Boutons de navigation
                        HStack {
                            // Bouton Précédent (visible à partir de la page 2)
                            if currentPageIndex > 0 {
                                Button(action: {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPageIndex -= 1
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text(LocalizationService.shared.currentLanguage == "fr" ? "Précédent" : "Previous")
                                    }
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 15)
                                    .background(.ultraThinMaterial, in: Capsule())
                                }
                                .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                            }
                            
                            Spacer()
                            
                            // Bouton principal (Suivant/Commencer)
                            Button(action: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                
                                if currentPageIndex < pages.count - 1 {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        currentPageIndex += 1
                                    }
                                } else {
                                    completeTutorial()
                                }
                            }) {
                                HStack {
                                    Text(currentPageIndex < pages.count - 1 
                                                                     ? (LocalizationService.shared.currentLanguage == "fr" ? "Suivant" : "Next")
                            : (LocalizationService.shared.currentLanguage == "fr" ? "Commencer" : "Get Started"))
                                    
                                    if currentPageIndex < pages.count - 1 {
                                        Image(systemName: "chevron.right")
                                    } else {
                                        Image(systemName: "arrow.right.circle.fill")
                                    }
                                }
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)
                                .background {
                                    if currentPageIndex < pages.count - 1 {
                                        Capsule()
                                            .fill(.ultraThinMaterial)
                                    } else {
                                        Capsule()
                                            .fill(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                    }
                                }
                                .scaleEffect(currentPageIndex == pages.count - 1 ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: currentPageIndex)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .statusBarHidden()
    }
    
    // MARK: - Actions
    
    /// Ignore le tutoriel
    private func skipTutorial() {
        tutorialService.completeTutorial()
        dismiss()
    }
    
    private func completeTutorial() {
        tutorialService.completeTutorial()
        
        // Feedback haptique de succès
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    TutorialView()
} 