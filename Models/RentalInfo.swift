import Foundation

struct RentalInfo: Codable, Identifiable {
    // Identifiant unique de la location
    let id: UUID
    
    // Référence au véhicule
    let vehicleId: UUID
    
    // Informations de base
    var startDate: Date
    var endDate: Date
    var dailyRate: Double
    var totalPrice: Double
    
    // Informations sur le locataire
    var renterName: String
    var renterPhone: String
    var renterEmail: String
    var renterLicenseNumber: String
    
    // État du véhicule
    var startMileage: Double
    var endMileage: Double?
    var startFuelLevel: Double // en pourcentage
    var endFuelLevel: Double? // en pourcentage
    
    // Statut de la location
    var status: RentalStatus
    var paymentStatus: PaymentStatus
    
    // Informations supplémentaires
    var notes: String?
    var damageReport: String?
    var photos: [String]? // URLs des photos
    
    // Initialisation
    init(id: UUID = UUID(), vehicleId: UUID, startDate: Date, endDate: Date,
         dailyRate: Double, renterName: String, renterPhone: String,
         renterEmail: String, renterLicenseNumber: String,
         startMileage: Double, startFuelLevel: Double) {
        self.id = id
        self.vehicleId = vehicleId
        self.startDate = startDate
        self.endDate = endDate
        self.dailyRate = dailyRate
        self.totalPrice = dailyRate * Calendar.current.dateComponents([.day], from: startDate, to: endDate).day!
        self.renterName = renterName
        self.renterPhone = renterPhone
        self.renterEmail = renterEmail
        self.renterLicenseNumber = renterLicenseNumber
        self.startMileage = startMileage
        self.startFuelLevel = startFuelLevel
        self.status = .scheduled
        self.paymentStatus = .pending
    }
}

// Statuts de location
enum RentalStatus: String, Codable {
    case scheduled = "Planifiée"
    case active = "En cours"
    case completed = "Terminée"
    case cancelled = "Annulée"
    case overdue = "En retard"
}

enum PaymentStatus: String, Codable {
    case pending = "En attente"
    case partial = "Partiel"
    case completed = "Payé"
    case overdue = "En retard"
    case refunded = "Remboursé"
} 