import SwiftUI
import AuthenticationServices

/// Vue SwiftUI pour afficher le bouton 'Se connecter avec Apple' et gérer la connexion
struct AppleSignInButtonView: View {
    @State private var signInStatus: String = ""
    @State private var isSignedIn: Bool = AppleSignInService.shared.userIdentifier != nil
    @State private var showAlert = false

    var body: some View {
        VStack(spacing: 20) {
            if isSignedIn {
                Text(L(CommonTranslations.connectedWithApple))
                    .font(.headline)
                Button(L(CommonTranslations.signOut)) {
                    AppleSignInService.shared.userIdentifier = nil
                    isSignedIn = false
                }
                .foregroundColor(.red)
            } else {
                SignInWithAppleButton(
                    .signIn,
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authResults):
                            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                AppleSignInService.shared.userIdentifier = appleIDCredential.user
                                isSignedIn = true
                                signInStatus = L(CommonTranslations.connectionSuccessful)
                            }
                        case .failure(let error):
                            signInStatus = "Erreur : \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 45)
            }
            if !signInStatus.isEmpty {
                Text(signInStatus)
                    .foregroundColor(isSignedIn ? .green : .red)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text(L(CommonTranslations.connectionError)), message: Text(signInStatus), dismissButton: .default(Text(L(CommonTranslations.ok))))
        }
    }
}

#Preview {
    AppleSignInButtonView()
}

/*
// Pour utiliser ce composant, il suffit de l'intégrer dans n'importe quelle vue SwiftUI :
AppleSignInButtonView()
*/ 