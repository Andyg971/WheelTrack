import Foundation

/// Énumération pour les périodes de temps dans les graphiques
public enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Semaine"
    case month = "Mois"
    case quarter = "Trimestre"
    case year = "Année"
    case all = "Tout"
    
    public var id: String { self.rawValue }
}

// Make it accessible at module level
public typealias WheelTrackTimeRange = TimeRange