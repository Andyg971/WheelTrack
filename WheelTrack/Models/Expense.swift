import Foundation

public struct Expense: Codable, Identifiable {
    // Identifiant unique de la dépense
    public let id: UUID
    
    // Référence au véhicule
    public let vehicleId: UUID
    
    // Informations de base
    public var date: Date
    public var amount: Double
    public var category: ExpenseCategory
    public var description: String
    
    // Informations supplémentaires
    public var mileage: Double? // Kilométrage au moment de la dépense
    public var receiptImageURL: String? // URL de l'image du reçu
    public var notes: String?
    
    // Initialisation
    public init(id: UUID = UUID(), vehicleId: UUID, date: Date, amount: Double,
         category: ExpenseCategory, description: String, mileage: Double? = nil,
         receiptImageURL: String? = nil, notes: String? = nil) {
        self.id = id
        self.vehicleId = vehicleId
        self.date = date
        self.amount = amount
        self.category = category
        self.description = description
        self.mileage = mileage
        self.receiptImageURL = receiptImageURL
        self.notes = notes
    }
}

// Catégories de dépenses
public enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case fuel = "Carburant"
    case maintenance = "Maintenance"
    case insurance = "Assurance"
    case tax = "Taxes"
    case parking = "Stationnement"
    case cleaning = "Nettoyage"
    case accessories = "Accessoires"
    case other = "Autre"
    
    public var id: String { self.rawValue }
} 