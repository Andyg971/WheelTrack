import SwiftUI

/// Vue d'onboarding simple qui ne s'affiche qu'au premier lancement
struct OnboardingView: View {
    @EnvironmentObject var appleSignInService: AppleSignInService
    @EnvironmentObject var localizationService: LocalizationService
    @State private var currentPage = 0
    
    // Palette de couleurs moderne 2025
    private let modernColors = [
        Color(red: 0.0, green: 0.48, blue: 1.0),   // Bleu WheelTrack (cohérent avec la marque)
        Color(red: 0.15, green: 0.75, blue: 0.35), // Vert émeraude 2025
        Color(red: 0.0, green: 0.55, blue: 0.95)   // Bleu cyber 2025
    ]
    
    private let pages = [
        OnboardingPage(
            title: "Bienvenue sur WheelTrack",
            description: "Gérez facilement vos véhicules, vos dépenses et votre maintenance",
            imageName: "car.2.fill",
            color: Color(red: 0.0, green: 0.48, blue: 1.0) // Bleu WheelTrack (cohérent avec la marque)
        ),
        OnboardingPage(
            title: "Trouvez Vos Garages",
            description: "Localisez facilement les garages et services automobiles près de chez vous",
            imageName: "location.fill",
            color: Color(red: 0.15, green: 0.75, blue: 0.35) // Vert émeraude moderne
        ),
        OnboardingPage(
            title: "Monétisez Votre Flotte",
            description: "Louez vos véhicules et générez des revenus supplémentaires",
            imageName: "key.fill",
            color: Color(red: 0.0, green: 0.55, blue: 0.95) // Bleu cyber moderne
        )
    ]
    
    var body: some View {
        ZStack {
            // Arrière-plan dégradé dynamique selon la page
            LinearGradient(
                gradient: Gradient(colors: [
                    modernColors[currentPage].opacity(0.15),
                    modernColors[currentPage].opacity(0.05),
                    Color(.systemBackground)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: currentPage)
            
            VStack(spacing: 0) {
                // Indicateur de page en haut avec couleurs dynamiques
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? modernColors[currentPage] : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                            .scaleEffect(index == currentPage ? 1.3 : 1.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // Contenu des pages (prend l'espace disponible)
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Boutons de navigation fixés en bas
                VStack(spacing: 16) {
                    if currentPage < pages.count - 1 {
                        Button("Continuer") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentPage += 1
                            }
                        }
                        .buttonStyle(ModernOnboardingButtonStyle(color: modernColors[currentPage]))
                        
                        Button("Passer") {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentPage = pages.count - 1
                            }
                        }
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                    } else {
                        // Dernière page - bouton Apple Sign In
                        AppleSignInButtonView()
                        
                        Text("En vous connectant, vous acceptez nos conditions d'utilisation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50) // Padding pour la safe area
            }
        }
    }
}

/// Page individuelle de l'onboarding
struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icône avec cercle coloré en arrière-plan
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(page.color)
            }
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(page.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

/// Modèle de données pour une page d'onboarding
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

/// Style de bouton moderne pour l'onboarding avec couleurs dynamiques
struct ModernOnboardingButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        color,
                        color.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppleSignInService.shared)
        .environmentObject(LocalizationService.shared)
} 
