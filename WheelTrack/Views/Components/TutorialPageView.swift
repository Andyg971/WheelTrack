import SwiftUI

/// Vue représentant une page individuelle du tutoriel
struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 40) {
                Spacer()
                
                // Icône
                Image(systemName: page.systemImage)
                    .font(.system(size: 80, weight: .medium))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 20) {
                    // Titre
                    Text(LocalizationService.shared.currentLanguage == "fr" ? page.title.0 : page.title.1)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    // Sous-titre
                    Text(LocalizationService.shared.currentLanguage == "fr" ? page.subtitle.0 : page.subtitle.1)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                    
                    // Description
                    Text(LocalizationService.shared.currentLanguage == "fr" ? page.description.0 : page.description.1)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .padding(.horizontal, 20)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 1)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                // Dégradé basé sur les couleurs de la page
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorFromString(page.gradientColors.0),
                        colorFromString(page.gradientColors.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .animation(.easeInOut(duration: 0.6), value: page.id)
    }
    
    // Fonction helper pour convertir les noms de couleurs en couleurs SwiftUI
    private func colorFromString(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        default: return .blue
        }
    }
}

// MARK: - Preview

#Preview {
    TutorialPageView(page: TutorialPage.pages.first!)
} 