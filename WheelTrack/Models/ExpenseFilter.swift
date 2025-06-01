import Foundation

public enum ExpenseFilter: String, CaseIterable, Identifiable {
    case all = "Toutes"
    case fuel = "Carburant"
    case maintenance = "Maintenance"
    case insurance = "Assurance"
    case tax = "Taxes"
    case parking = "Stationnement"
    case cleaning = "Nettoyage"
    case accessories = "Accessoires"
    case other = "Autres"
    
    public var id: String { self.rawValue }
} 