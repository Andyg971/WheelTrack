import Foundation
import AuthenticationServices

/// Service pour gérer l'authentification avec Sign in with Apple
final class AppleSignInService: NSObject, ObservableObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static let shared = AppleSignInService()
    
    override init() {
        super.init()
        loadUserIdentifier()
    }

    /// Stocke l'identifiant utilisateur Apple (persistant si besoin)
    @Published var userIdentifier: String? {
        didSet {
            if let id = userIdentifier {
                UserDefaults.standard.set(id, forKey: "appleUserIdentifier")
            } else {
                UserDefaults.standard.removeObject(forKey: "appleUserIdentifier")
            }
        }
    }

    // Initialisation de la valeur à partir de UserDefaults
    func loadUserIdentifier() {
        DispatchQueue.main.async {
            self.userIdentifier = UserDefaults.standard.string(forKey: "appleUserIdentifier")
        }
    }

    /// Lance le flux de connexion Apple
    func startSignInWithAppleFlow(presentationAnchor: ASPresentationAnchor, completion: @escaping (Result<String, Error>) -> Void) {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        self.completion = completion
        self.presentationAnchor = presentationAnchor
        controller.performRequests()
    }
    
    /// Gère la connexion avec les informations d'identification Apple
    func signIn(with credential: ASAuthorizationAppleIDCredential) {
        // Sauvegarder l'identifiant utilisateur
        DispatchQueue.main.async {
            self.userIdentifier = credential.user
        }
        // Traiter les informations de l'utilisateur
        if let fullName = credential.fullName {
            let givenName = fullName.givenName ?? ""
            let familyName = fullName.familyName ?? ""
            print("Nom complet: \(givenName) \(familyName)")
        }
        if let email = credential.email {
            print("Email: \(email)")
        }
        // Notifier que la connexion est réussie
        NotificationCenter.default.post(name: .userDidSignIn, object: nil)
    }

    func signOut() {
        self.userIdentifier = nil
    }

    // MARK: - ASAuthorizationControllerDelegate
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            print("🎉 Apple Sign In authorization réussie!")
            signIn(with: appleIDCredential)
            completion?(.success(appleIDCredential.user))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("❌ Apple Sign In error: \(error.localizedDescription)")
        completion?(.failure(error))
    }
    
    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return presentationAnchor!
    }

    // MARK: - Privé
    private var completion: ((Result<String, Error>) -> Void)?
    private var presentationAnchor: ASPresentationAnchor?
}

extension Notification.Name {
    static let userDidSignIn = Notification.Name("userDidSignIn")
}

/*
// Exemple d'utilisation dans une vue SwiftUI :
AppleSignInService.shared.startSignInWithAppleFlow(presentationAnchor: window) { result in
    switch result {
    case .success(let userID):
        print("Connecté avec l'identifiant Apple :", userID)
    case .failure(let error):
        print("Erreur de connexion :", error)
    }
}
*/ 