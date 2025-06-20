import SwiftUI

/// Vue d'onboarding simple qui ne s'affiche qu'au premier lancement
struct OnboardingView: View {
    @EnvironmentObject var appleSignInService: AppleSignInService
    @EnvironmentObject var localizationService: LocalizationService
    @State private var currentPage = 0
    
    // Couleur principale de WheelTrack basée sur le logo
    private let wheelTrackBlue = Color(red: 0.2, green: 0.7, blue: 1.0)
    
    private let pages = [
        OnboardingPage(
            title: "Bienvenue sur WheelTrack",
            description: "Gérez facilement vos véhicules, vos dépenses et votre maintenance automobile",
            imageName: "car.2.fill",
            color: Color(red: 0.2, green: 0.7, blue: 1.0) // Couleur cohérente du logo
        ),
        OnboardingPage(
            title: "Trouvez vos garages",
            description: "Localisez facilement les garages et services automobiles autour de vous grâce à la géolocalisation",
            imageName: "location.fill",
            color: Color(red: 0.2, green: 0.7, blue: 1.0) // Couleur cohérente du logo
        ),
        OnboardingPage(
            title: "Louez vos véhicules",
            description: "Créez des contrats de location, gérez vos locataires et générez des revenus avec vos véhicules",
            imageName: "key.fill",
            color: Color(red: 0.2, green: 0.7, blue: 1.0) // Couleur cohérente du logo
        )
    ]
    
    var body: some View {
        ZStack {
            // Arrière-plan dégradé
            LinearGradient(
                gradient: Gradient(colors: [
                    wheelTrackBlue.opacity(0.1),
                    wheelTrackBlue.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Indicateur de page en haut
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? wheelTrackBlue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
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
                        .buttonStyle(PrimaryButtonStyle())
                        
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

/// Style de bouton principal
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.7, blue: 1.0),
                        Color(red: 0.1, green: 0.6, blue: 0.9)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

/// Modèle de données pour une page d'onboarding
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

#Preview {
    OnboardingView()
        .environmentObject(AppleSignInService.shared)
        .environmentObject(LocalizationService.shared)
} 