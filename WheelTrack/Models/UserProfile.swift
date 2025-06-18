import Foundation

public struct UserProfile: Codable {
    // MARK: - Informations Personnelles
    public var firstName: String = ""
    public var lastName: String = ""
    public var email: String = ""
    public var phoneNumber: String = ""
    public var dateOfBirth: Date?
    public var profileImageData: Data? // Pour stocker l'image de profil
    
    // MARK: - Adresse
    public var streetAddress: String = ""
    public var city: String = ""
    public var postalCode: String = ""
    public var country: String = "France"
    
    // MARK: - Permis de Conduire
    public var drivingLicenseNumber: String = ""
    public var licenseObtainedDate: Date?
    public var licenseExpirationDate: Date?
    public var licenseCategories: [String] = ["B"] // A, B, C, D, etc.
    
    // MARK: - Assurance Principale
    public var insuranceCompany: String = ""
    public var insurancePolicyNumber: String = ""
    public var insuranceContactPhone: String = ""
    public var insuranceExpirationDate: Date?
    
    // MARK: - Informations Professionnelles
    public var profession: String = ""
    public var company: String = ""
    public var professionalVehicleUsagePercentage: Double = 0.0 // 0-100%
    
    // MARK: - Préférences de l'App
    public var preferredCurrency: String = "EUR"
    public var distanceUnit: DistanceUnit = .kilometers
    public var fuelConsumptionUnit: FuelConsumptionUnit = .litersPerHundredKm
    public var language: String = "fr"
    public var enableNotifications: Bool = true
    public var enableMaintenanceReminders: Bool = true
    public var enableInsuranceReminders: Bool = true
    public var enableLicenseReminders: Bool = true
    
    // MARK: - Paramètres Financiers
    public var defaultVATRate: Double = 20.0 // Taux de TVA par défaut (%)
    public var professionalDeductionRate: Double = 0.0 // Taux de déduction pro (%)
    public var monthlyVehicleBudget: Double = 0.0
    
    // MARK: - Métadonnées
    public var createdAt: Date = Date()
    public var lastUpdated: Date = Date()
    
    public init() {}
}

// MARK: - Enums pour les unités
public enum DistanceUnit: String, CaseIterable, Codable {
    case kilometers = "km"
    case miles = "mi"
    
    public var displayName: String {
        switch self {
        case .kilometers: return "Kilomètres"
        case .miles: return "Miles"
        }
    }
}

public enum FuelConsumptionUnit: String, CaseIterable, Codable {
    case litersPerHundredKm = "L/100km"
    case milesPerGallon = "MPG"
    case kilometersPerLiter = "km/L"
    
    public var displayName: String {
        switch self {
        case .litersPerHundredKm: return "Litres/100km"
        case .milesPerGallon: return "Miles/Gallon"
        case .kilometersPerLiter: return "Kilomètres/Litre"
        }
    }
}

// MARK: - Extensions pour l'affichage
extension UserProfile {
    public var fullName: String {
        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
    
    public var isComplete: Bool {
        return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
    }
    
    public var hasValidLicense: Bool {
        guard let expirationDate = licenseExpirationDate else { return false }
        return expirationDate > Date()
    }
    
    public var hasValidInsurance: Bool {
        guard let expirationDate = insuranceExpirationDate else { return false }
        return expirationDate > Date()
    }
    
    // Nombre de jours avant expiration du permis
    public var daysUntilLicenseExpiration: Int? {
        guard let expirationDate = licenseExpirationDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day
    }
    
    // Nombre de jours avant expiration de l'assurance
    public var daysUntilInsuranceExpiration: Int? {
        guard let expirationDate = insuranceExpirationDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day
    }
}