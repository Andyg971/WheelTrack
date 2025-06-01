import Foundation

struct VehicleSearchFilter: Codable {
    // Filtres de base
    var brand: String?
    var model: String?
    var yearRange: ClosedRange<Int>?
    var priceRange: ClosedRange<Double>?
    var mileageRange: ClosedRange<Double>?
    
    // Filtres techniques
    var fuelType: FuelType?
    var transmission: TransmissionType?
    var color: String?
    
    // Filtres de localisation
    var location: String?
    var radius: Double? // en kilomètres
    
    // Filtres de disponibilité
    var isAvailableForRent: Bool?
    var isAvailableForSale: Bool?
    
    // Filtres de caractéristiques
    var hasAirConditioning: Bool?
    var hasGPS: Bool?
    var hasBluetooth: Bool?
    var hasBackupCamera: Bool?
    
    // Tri
    var sortBy: SortOption
    var sortOrder: SortOrder
    
    // Initialisation
    init(sortBy: SortOption = .price, sortOrder: SortOrder = .ascending) {
        self.sortBy = sortBy
        self.sortOrder = sortOrder
    }
}

// Options de tri
enum SortOption: String, Codable {
    case price = "Prix"
    case year = "Année"
    case mileage = "Kilométrage"
    case dateAdded = "Date d'ajout"
    case popularity = "Popularité"
}

enum SortOrder: String, Codable {
    case ascending = "Croissant"
    case descending = "Décroissant"
} 