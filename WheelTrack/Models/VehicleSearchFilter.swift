import Foundation

public struct VehicleSearchFilter: Codable {
    // Filtres de base
    public var brand: String?
    public var model: String?
    public var yearRange: ClosedRange<Int>?
    public var priceRange: ClosedRange<Double>?
    public var mileageRange: ClosedRange<Double>?
    
    // Filtres techniques
    public var fuelType: FuelType?
    public var transmission: TransmissionType?
    public var color: String?
    
    // Filtres de localisation
    public var location: String?
    public var radius: Double? // en kilomètres
    
    // Filtres de disponibilité
    public var isAvailableForRent: Bool?
    public var isAvailableForSale: Bool?
    
    // Filtres de caractéristiques
    public var hasAirConditioning: Bool?
    public var hasGPS: Bool?
    public var hasBluetooth: Bool?
    public var hasBackupCamera: Bool?
    
    // Tri
    public var sortBy: SortOption
    public var sortOrder: SortOrder
    
    // Initialisation
    public init(sortBy: SortOption = .price, sortOrder: SortOrder = .ascending) {
        self.sortBy = sortBy
        self.sortOrder = sortOrder
    }
}

// Options de tri
public enum SortOption: String, Codable {
    case price = "Prix"
    case year = "Année"
    case mileage = "Kilométrage"
    case dateAdded = "Date d'ajout"
    case popularity = "Popularité"
}

public enum SortOrder: String, Codable {
    case ascending = "Croissant"
    case descending = "Décroissant"
} 