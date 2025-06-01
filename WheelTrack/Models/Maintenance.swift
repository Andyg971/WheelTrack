import Foundation

public struct Maintenance: Identifiable, Codable, Equatable {
    public let id: UUID
    public var titre: String
    public var date: Date
    public var cout: Double
    public var kilometrage: Int
    public var description: String
    public var garage: String
    public var vehicule: String
    
    public init(id: UUID = UUID(), titre: String, date: Date, cout: Double, kilometrage: Int, description: String, garage: String, vehicule: String) {
        self.id = id
        self.titre = titre
        self.date = date
        self.cout = cout
        self.kilometrage = kilometrage
        self.description = description
        self.garage = garage
        self.vehicule = vehicule
    }
} 