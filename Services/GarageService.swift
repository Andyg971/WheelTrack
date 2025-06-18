import Foundation
import CoreLocation

class GarageService {
    // Instance singleton
    static let shared = GarageService()
    
    // MARK: - Propriétés
    
    private let dataManager = DataManager.shared
    
    // MARK: - Méthodes publiques
    
    func searchGarages(near location: CLLocation, radius: Double, completion: @escaping (Result<[Garage], Error>) -> Void) {
        // Dans une vraie application, on appellerait une API externe
        // Pour l'instant, on filtre les garages existants
        let garages = dataManager.getAllGarages()
        let nearbyGarages = garages.filter { garage in
            let garageLocation = CLLocation(latitude: garage.latitude, longitude: garage.longitude)
            let distance = calculateDistance(from: location, to: garageLocation)
            return distance <= radius * 1000 // Conversion en mètres
        }
        
        completion(.success(nearbyGarages))
    }
    
    func getGarageDetails(id: UUID) -> Garage? {
        return dataManager.getGarage(id: id)
    }
    
    func addGarage(_ garage: Garage) {
        dataManager.addGarage(garage)
    }
    
    func updateGarage(_ garage: Garage) {
        // À implémenter dans DataManager
        // dataManager.updateGarage(garage)
    }
    
    func deleteGarage(_ garage: Garage) {
        // À implémenter dans DataManager  
        // dataManager.deleteGarage(garage)
    }
    
    func getGaragesByService(_ service: String) -> [Garage] {
        let garages = dataManager.getAllGarages()
        return garages.filter { $0.services.contains(service) }
    }
    
    func getGaragesBySpecialty(_ specialty: String) -> [Garage] {
        let garages = dataManager.getAllGarages()
        return garages.filter { $0.specialties.contains(specialty) }
    }
    
    func getGaragesByRating(minimumRating: Double) -> [Garage] {
        let garages = dataManager.getAllGarages()
        return garages.filter { ($0.rating ?? 0) >= minimumRating }
    }
    
    func getGaragesByOpeningHours(day: DayOfWeek, time: String) -> [Garage] {
        let garages = dataManager.getAllGarages()
        return garages.filter { garage in
            guard let hours = garage.openingHours[day] else { return false }
            return !hours.isClosed && hours.openTime <= time && hours.closeTime >= time
        }
    }
    
    // MARK: - Méthodes utilitaires
    
    func formatOpeningHours(_ hours: [DayOfWeek: OpeningHours]) -> String {
        var formattedHours: [String] = []
        
        for (day, openingHours) in hours {
            if openingHours.isClosed {
                formattedHours.append("\(day.rawValue): Fermé")
            } else {
                formattedHours.append("\(day.rawValue): \(openingHours.openTime) - \(openingHours.closeTime)")
            }
        }
        
        return formattedHours.joined(separator: "\n")
    }
    
    func calculateDistance(from source: CLLocation, to garage: Garage) -> CLLocationDistance {
        let garageLocation = CLLocation(latitude: garage.latitude, longitude: garage.longitude)
        return source.distance(from: garageLocation)
    }
    
    func getDirections(to garage: Garage, completion: @escaping (Result<String, Error>) -> Void) {
        // Dans une vraie application, on utiliserait MapKit pour obtenir les directions
        // Pour l'instant, on retourne simplement l'adresse
        completion(.success(garage.address))
    }
} 