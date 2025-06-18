import Foundation

public enum ExpenseFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case fuel = "fuel"
    case maintenance = "maintenance"
    case insurance = "insurance"
    case tax = "tax"
    case parking = "parking"
    case cleaning = "cleaning"
    case accessories = "accessories"
    case other = "other"
    
    public var id: String { self.rawValue }
    
    // MARK: - Localization
    public func localizedName(language: String = "fr") -> String {
        switch (self, language) {
        case (.all, "en"): return "All"
        case (.all, _): return "Toutes"
        case (.fuel, "en"): return "Fuel"
        case (.fuel, _): return "Carburant"
        case (.maintenance, "en"): return "Maintenance"
        case (.maintenance, _): return "Entretien"
        case (.insurance, "en"): return "Insurance"
        case (.insurance, _): return "Assurance"
        case (.tax, "en"): return "Taxes"
        case (.tax, _): return "Taxes"
        case (.parking, "en"): return "Parking"
        case (.parking, _): return "Stationnement"
        case (.cleaning, "en"): return "Cleaning"
        case (.cleaning, _): return "Nettoyage"
        case (.accessories, "en"): return "Accessories"
        case (.accessories, _): return "Accessoires"
        case (.other, "en"): return "Other"
        case (.other, _): return "Autres"
        }
    }
} 