import Foundation
import CoreLocation

public struct Garage: Identifiable, Codable, Equatable {
    public let id: UUID // Identifiant unique
    public var nom: String // Nom du garage
    public var adresse: String // Adresse postale
    public var ville: String // Ville
    public var telephone: String // Numéro de téléphone
    public var services: [String] // Liste des services proposés
    public var horaires: String // Horaires d'ouverture
    public var latitude: Double // Latitude GPS
    public var longitude: Double // Longitude GPS
    public var isFavorite: Bool // Indique si le garage est en favori
    
    public init(id: UUID, nom: String, adresse: String, ville: String, telephone: String, services: [String], horaires: String, latitude: Double, longitude: Double, isFavorite: Bool) {
        self.id = id
        self.nom = nom
        self.adresse = adresse
        self.ville = ville
        self.telephone = telephone
        self.services = services
        self.horaires = horaires
        self.latitude = latitude
        self.longitude = longitude
        self.isFavorite = isFavorite
    }
} 