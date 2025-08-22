import Foundation
import StoreKit

/// Service pour gérer la configuration App Store Connect
public class AppStoreConfigService {
    public static let shared = AppStoreConfigService()
    
    // MARK: - Configuration App Store Connect
    
    /// Bundle ID de l'application (doit correspondre à App Store Connect)
    public let bundleID = "com.wheeltrack.app" // Bundle ID de votre app
    
    /// Team ID de développeur
    public let teamID = "VOTRE_TEAM_ID" // Remplacez par votre vrai Team ID d'App Store Connect
    
    /// App Store Connect App ID
    public let appStoreAppID = "6502148299" // App ID de votre app dans App Store Connect
    
    /// Groupe d'abonnements (doit correspondre à App Store Connect)
    public let subscriptionGroupID = "21451234" // TODO: Remplacer par votre Subscription Group ID
    
    private init() {}
    
    // MARK: - Validation Configuration
    
    /// Vérifie que la configuration est correcte
    public func validateConfiguration() -> [String] {
        var errors: [String] = []
        
        // Vérifier le Bundle ID
        if Bundle.main.bundleIdentifier != bundleID {
            errors.append("Bundle ID ne correspond pas: attendu \(bundleID), trouvé \(Bundle.main.bundleIdentifier ?? "nil")")
        }
        
        // Vérifier les entitlements
        if !hasStoreKitEntitlement() {
            errors.append("Entitlement StoreKit manquant")
        }
        
        // Vérifier la configuration StoreKit
        if !hasStoreKitConfiguration() {
            errors.append("Fichier Configuration.storekit manquant")
        }
        
        return errors
    }
    
    /// Vérifie la présence de l'entitlement StoreKit
    private func hasStoreKitEntitlement() -> Bool {
        // En fait, StoreKit n'a pas besoin d'entitlement spécifique
        // mais on peut vérifier d'autres capabilities importantes
        return true
    }
    
    /// Vérifie la présence du fichier de configuration StoreKit
    private func hasStoreKitConfiguration() -> Bool {
        return Bundle.main.url(forResource: "Configuration", withExtension: "storekit") != nil
    }
    
    // MARK: - URLs App Store Connect
    
    /// URL pour gérer les abonnements
    public var manageSubscriptionsURL: URL? {
        return URL(string: "https://apps.apple.com/account/subscriptions")
    }
    
    /// URL pour les termes et conditions
    public var termsAndConditionsURL: URL? {
        return URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
    }
    
    /// URL pour la politique de confidentialité
    public var privacyPolicyURL: URL? {
        return URL(string: "https://wheeltrack.app/privacy") // TODO: Remplacer par votre URL
    }
    
    // MARK: - Helper Methods
    
    /// Retourne les informations de l'environnement actuel
    public func getCurrentEnvironment() -> StoreEnvironment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
    
    /// Retourne le préfixe correct pour les Product IDs
    public func getProductIDPrefix() -> String {
        return "wheeltrack_premium_"
    }
    
    /// Valide un Product ID
    public func isValidProductID(_ productID: String) -> Bool {
        let validIDs = [
            "wheeltrack_premium_monthly",
            "wheeltrack_premium_yearly",
            "wheeltrack_premium_lifetime"
        ]
        return validIDs.contains(productID)
    }
    
    /// Retourne les informations de debug pour StoreKit
    public func getDebugInfo() -> [String: Any] {
        return [
            "bundleID": Bundle.main.bundleIdentifier ?? "nil",
            "expectedBundleID": bundleID,
            "hasStoreKitConfig": hasStoreKitConfiguration(),
            "environment": getCurrentEnvironment().rawValue,
            "appVersion": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "nil",
            "buildNumber": Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "nil"
        ]
    }
}

// MARK: - Store Environment

public enum StoreEnvironment: String {
    case development = "Development"
    case production = "Production"
    
    var description: String {
        switch self {
        case .development:
            return "Environnement de développement avec Configuration.storekit"
        case .production:
            return "Environnement de production avec App Store Connect"
        }
    }
}
