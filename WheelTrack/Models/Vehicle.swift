import Foundation

public struct Vehicle: Codable, Identifiable {
    // Identifiant unique du véhicule
    public let id: UUID
    
    // Informations de base
    public var brand: String
    public var model: String
    public var year: Int
    public var licensePlate: String
    
    // Caractéristiques techniques
    public var mileage: Double // en kilomètres
    public var fuelType: FuelType
    public var transmission: TransmissionType
    public var color: String
    
    // Informations d'achat
    public var purchaseDate: Date
    public var purchasePrice: Double
    public var purchaseMileage: Double
    
    // Informations de maintenance
    public var lastMaintenanceDate: Date?
    public var nextMaintenanceDate: Date?
    
    // Informations de revente
    public var estimatedValue: Double?
    public var resaleDate: Date?
    public var resalePrice: Double?
    
    // Informations de location
    public var isAvailableForRent: Bool = false
    public var rentalPrice: Double?
    public var depositAmount: Double? // Caution
    public var minimumRentalDays: Int? // Durée minimum de location
    public var maximumRentalDays: Int? // Durée maximum de location
    public var vehicleDescription: String? // Description pour les locataires
    public var privateNotes: String? // Notes privées
    
    // Statut du véhicule
    public var isActive: Bool = true
    
    // Initialisation
    public init(id: UUID = UUID(), brand: String, model: String, year: Int, licensePlate: String,
         mileage: Double, fuelType: FuelType, transmission: TransmissionType, color: String,
         purchaseDate: Date, purchasePrice: Double, purchaseMileage: Double) {
        self.id = id
        self.brand = brand
        self.model = model
        self.year = year
        self.licensePlate = licensePlate
        self.mileage = mileage
        self.fuelType = fuelType
        self.transmission = transmission
        self.color = color
        self.purchaseDate = purchaseDate
        self.purchasePrice = purchasePrice
        self.purchaseMileage = purchaseMileage
    }
}

// Types énumérés pour les propriétés spécifiques
public enum FuelType: String, Codable, CaseIterable, Identifiable {
    case gasoline = "Essence"
    case diesel = "Diesel"
    case electric = "Électrique"
    case hybrid = "Hybride"
    case lpg = "GPL"
    
    public var id: String { self.rawValue }
}

public enum TransmissionType: String, Codable, CaseIterable, Identifiable {
    case manual = "Manuelle"
    case automatic = "Automatique"
    case semiAutomatic = "Semi-automatique"
    
    public var id: String { self.rawValue }
} 