import Foundation

/// Énumération pour les périodes de temps dans les graphiques
public enum TimeRange: String, CaseIterable, Identifiable {
    case week = "week"
    case month = "month"
    case quarter = "quarter"
    case year = "year"
    case all = "all"
    
    public var id: String { self.rawValue }
    
    /// Retourne le libellé localisé pour la période
    public func localizedName(language: String = "fr") -> String {
        switch self {
        case .week:
            return language == "en" ? "Week" : "Semaine"
        case .month:
            return language == "en" ? "Month" : "Mois"
        case .quarter:
            return language == "en" ? "Quarter" : "Trimestre"
        case .year:
            return language == "en" ? "Year" : "Année"
        case .all:
            return language == "en" ? "All" : "Tout"
        }
    }
}

// Make it accessible at module level
public typealias WheelTrackTimeRange = TimeRange