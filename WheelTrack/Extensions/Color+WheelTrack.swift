import SwiftUI

extension Color {
    // MARK: - Couleurs pour les types de carburant
    
    /// Couleur pour les véhicules électriques - Jaune éclatant
    static let electricYellow = Color(red: 1.0, green: 0.84, blue: 0.0)
    
    /// Couleur pour les véhicules essence - Bleu vif
    static let gasolineBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    
    /// Couleur pour les véhicules diesel - Orange énergique
    static let dieselOrange = Color(red: 1.0, green: 0.58, blue: 0.0)
    
    /// Couleur pour les véhicules hybrides - Vert écologique
    static let hybridGreen = Color(red: 0.2, green: 0.8, blue: 0.2)
    
    /// Couleur pour les véhicules GPL - Violet distinctif
    static let lpgPurple = Color(red: 0.6, green: 0.2, blue: 0.8)
    
    // MARK: - Couleurs de l'application
    
    /// Couleur d'accent principale de l'application
    static let wheelTrackBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    
    /// Couleur secondaire
    static let wheelTrackGray = Color(red: 0.5, green: 0.5, blue: 0.5)
}

// MARK: - Extension pour les types de carburant
extension FuelType {
    /// Couleur associée au type de carburant
    var color: Color {
        switch self {
        case .electric:
            return .electricYellow
        case .gasoline:
            return .gasolineBlue
        case .diesel:
            return .dieselOrange
        case .hybrid:
            return .hybridGreen
        case .lpg:
            return .lpgPurple
        }
    }
    
    /// Icône SF Symbol principale pour le type de carburant
    var icon: String {
        switch self {
        case .electric:
            return "bolt.fill"
        case .gasoline:
            return "drop.fill"
        case .diesel:
            return "fuelpump.fill"
        case .hybrid:
            return "leaf.arrow.circlepath"
        case .lpg:
            return "flame.fill"
        }
    }
    
    /// Icône de véhicule spécifique et distinctive
    var vehicleIcon: String {
        switch self {
        case .electric:
            return "ev.charger.fill"
        case .gasoline:
            return "car.fill"
        case .diesel:
            return "truck.box.fill"
        case .hybrid:
            return "car.2.fill"
        case .lpg:
            return "car.circle.fill"
        }
    }
    
    /// Icône alternative plus expressive pour les interfaces
    var expressiveIcon: String {
        switch self {
        case .electric:
            return "ev.plug.ac.gb.t"
        case .gasoline:
            return "drop.circle.fill"
        case .diesel:
            return "fuelpump.circle.fill"
        case .hybrid:
            return "leaf.circle.fill"
        case .lpg:
            return "flame.circle.fill"
        }
    }
    
    /// Icône pour les sélecteurs de formulaire
    var formIcon: String {
        switch self {
        case .electric:
            return "bolt.circle.fill"
        case .gasoline:
            return "drop.triangle.fill"
        case .diesel:
            return "fuelpump.arrow.triangle.fill"
        case .hybrid:
            return "arrow.triangle.2.circlepath.circle.fill"
        case .lpg:
            return "flame.circle.fill"
        }
    }
    
    /// Icône d'overlay pour le symbole sur la voiture
    var overlayIcon: String {
        switch self {
        case .electric:
            return "bolt.fill"
        case .gasoline:
            return "drop.fill"
        case .diesel:
            return "fuelpump.fill"
        case .hybrid:
            return "leaf.fill"
        case .lpg:
            return "flame.fill"
        }
    }
} 