import SwiftUI
import AuthenticationServices

/// Vue SwiftUI pour afficher le bouton 'Se connecter avec Apple' et gérer la connexion
struct AppleSignInButtonView: View {
    @EnvironmentObject var appleSignInService: AppleSignInService
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        Button(action: signInWithApple) {
            HStack(spacing: 12) {
                Image(systemName: "applelogo")
                    .font(.system(size: 20, weight: .medium))
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Text("Se connecter avec Apple")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.black)
            .cornerRadius(12)
        }
        .disabled(isLoading)
        .alert("Erreur de connexion", isPresented: $showAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func signInWithApple() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            alertMessage = "Impossible d'accéder à la fenêtre de l'application"
            showAlert = true
            return
        }
        
        isLoading = true
        
        appleSignInService.startSignInWithAppleFlow(presentationAnchor: window) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let userID):
                    print("✅ Connexion réussie avec l'identifiant: \(userID)")
                    // La notification .userDidSignIn est envoyée automatiquement par AppleSignInService
                    
                case .failure(let error):
                    print("❌ Erreur de connexion: \(error.localizedDescription)")
                    alertMessage = "La connexion a échoué. Veuillez réessayer."
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    AppleSignInButtonView()
        .environmentObject(AppleSignInService.shared)
        .padding()
}

/*
// Pour utiliser ce composant, il suffit de l'intégrer dans n'importe quelle vue SwiftUI :
AppleSignInButtonView()
*/ 