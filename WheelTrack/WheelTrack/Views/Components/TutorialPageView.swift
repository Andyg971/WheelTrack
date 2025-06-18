import SwiftUI

/// Vue représentant une page individuelle du tutoriel
struct TutorialPageView: View {
    let page: TutorialPage
    @StateObject private var localizationService = LocalizationService.shared
    @State private var isAnimated = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Arrière-plan avec gradient
                LinearGradient(
                    colors: [
                        Color(page.backgroundColor),
                        Color(page.backgroundColor).opacity(0.8)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Icône principale avec animation
                    Image(systemName: page.systemImageName)
                        .font(.system(size: 120, weight: .light))
                        .foregroundColor(Color(page.foregroundColor))
                        .scaleEffect(isAnimated ? 1.0 : 0.5)
                        .opacity(isAnimated ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: isAnimated)
                    
                    VStack(spacing: 20) {
                        // Titre principal
                        Text(localizationService.text(page.title.0, page.title.1))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color(page.foregroundColor))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .opacity(isAnimated ? 1.0 : 0.0)
                            .offset(y: isAnimated ? 0 : 20)
                            .animation(.easeOut(duration: 0.8).delay(0.3), value: isAnimated)
                        
                        // Sous-titre
                        Text(localizationService.text(page.subtitle.0, page.subtitle.1))
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(Color(page.foregroundColor).opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                            .opacity(isAnimated ? 1.0 : 0.0)
                            .offset(y: isAnimated ? 0 : 20)
                            .animation(.easeOut(duration: 0.8).delay(0.5), value: isAnimated)
                        
                        // Description détaillée
                        Text(localizationService.text(page.description.0, page.description.1))
                            .font(.body)
                            .foregroundColor(Color(page.foregroundColor).opacity(0.8))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 40)
                            .padding(.top, 10)
                            .opacity(isAnimated ? 1.0 : 0.0)
                            .offset(y: isAnimated ? 0 : 20)
                            .animation(.easeOut(duration: 0.8).delay(0.7), value: isAnimated)
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 50)
            }
        }
        .onAppear {
            withAnimation {
                isAnimated = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    TutorialPageView(page: TutorialPage.pages[0])
} 