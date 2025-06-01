import Foundation

struct Expense: Codable, Identifiable {
    // Identifiant unique de la dépense
    let id: UUID
    
    // Référence au véhicule
    let vehicleId: UUID
    
    // Informations de base
    var date: Date
    var amount: Double
    var category: ExpenseCategory
    var description: String
    
    // Informations supplémentaires
    var mileage: Double? // Kilométrage au moment de la dépense
    var receiptImageURL: String? // URL de l'image du reçu
    var notes: String?
    
    // Initialisation
    init(id: UUID = UUID(), vehicleId: UUID, date: Date, amount: Double,
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
enum ExpenseCategory: String, Codable {
    case fuel = "Carburant"
    case maintenance = "Maintenance"
    case insurance = "Assurance"
    case tax = "Taxes"
    case parking = "Stationnement"
    case cleaning = "Nettoyage"
    case accessories = "Accessoires"
    case other = "Autre"
} 