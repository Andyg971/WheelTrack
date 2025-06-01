import Foundation
import CoreLocation

struct Garage: Codable, Identifiable {
    // Identifiant unique du garage
    let id: UUID
    
    // Informations de base
    var name: String
    var address: String
    var phoneNumber: String?
    var email: String?
    var website: String?
    
    // Localisation
    var latitude: Double
    var longitude: Double
    
    // Services proposés
    var services: [GarageService]
    var specialties: [String]
    
    // Horaires d'ouverture
    var openingHours: [DayOfWeek: OpeningHours]
    
    // Évaluations et notes
    var rating: Double?
    var numberOfReviews: Int
    
    // Informations supplémentaires
    var notes: String?
    var isFavorite: Bool
    
    // Initialisation
    init(id: UUID = UUID(), name: String, address: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.services = []
        self.specialties = []
        self.openingHours = [:]
        self.numberOfReviews = 0
        self.isFavorite = false
    }
}

// Types énumérés pour les services et horaires
enum GarageService: String, Codable {
    case generalMaintenance = "Maintenance générale"
    case diagnostics = "Diagnostic"
    case bodyWork = "Carrosserie"
    case paint = "Peinture"
    case electrical = "Électricité"
    case engine = "Moteur"
    case transmission = "Transmission"
    case brakes = "Freins"
    case tires = "Pneus"
    case airConditioning = "Climatisation"
}

enum DayOfWeek: String, Codable {
    case monday = "Lundi"
    case tuesday = "Mardi"
    case wednesday = "Mercredi"
    case thursday = "Jeudi"
    case friday = "Vendredi"
    case saturday = "Samedi"
    case sunday = "Dimanche"
}

struct OpeningHours: Codable {
    var openTime: String // Format "HH:mm"
    var closeTime: String // Format "HH:mm"
    var isClosed: Bool
} 