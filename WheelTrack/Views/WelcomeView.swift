import SwiftUI
import AuthenticationServices

/// Vue d'accueil avec le bouton 'Se connecter avec Apple'
public struct WelcomeView: View {
    @ObservedObject private var signInService = AppleSignInService.shared
    public init() {
        signInService.loadUserIdentifier()
    }
    
    public var body: some View {
        VStack(spacing: 30) {
            // Logo et titre
            VStack(spacing: 20) {
                Image(systemName: "car.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("WheelTrack")
                    .font(.largeTitle)
                    .bold()
                
                Text("Gérez vos véhicules en toute simplicité")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Fonctionnalités
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "speedometer", title: "Suivi kilométrage", description: "Gardez un œil sur vos distances parcourues")
                FeatureRow(icon: "fuelpump.fill", title: "Dépenses carburant", description: "Suivez vos dépenses en carburant")
                FeatureRow(icon: "wrench.fill", title: "Maintenance", description: "Planifiez vos entretiens")
                FeatureRow(icon: "chart.bar.fill", title: "Statistiques", description: "Analysez vos coûts")
            }
            .padding()
            
            Spacer()
            
            // Bouton de connexion Apple ou déconnexion
            if signInService.userIdentifier == nil {
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                AppleSignInService.shared.signIn(with: appleIDCredential)
                            }
                        case .failure(let error):
                            print("Erreur de connexion: \(error.localizedDescription)")
                        }
                    }
                )
                .frame(height: 50)
                .padding(.horizontal, 40)
            } else {
                Button("Se déconnecter") {
                    signInService.signOut()
                }
                .frame(height: 50)
                .padding(.horizontal, 40)
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
            }
            
            // Mentions légales
            Text("En continuant, vous acceptez nos conditions d'utilisation")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 30)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    WelcomeView()
} 