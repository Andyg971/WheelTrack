import Foundation

/// Gestion centralisée des clés API et secrets de l'application
/// Les secrets sont stockés dans Secrets.plist (non versionné dans Git)
enum Secrets {
    
    /// Clé API Google Places pour récupérer les horaires des garages
    static var googlePlacesKey: String {
        guard
            let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
            let key = plist["GOOGLE_PLACES_API_KEY"] as? String,
            !key.isEmpty,
            key != "COLLEZ_VOTRE_CLE_API_ICI"
        else {
            assertionFailure("⚠️ Clé Google Places manquante dans Secrets.plist")
            return ""
        }
        return key
    }
}

