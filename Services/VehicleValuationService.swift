import Foundation
import WheelTrack

class VehicleValuationService {
    // Instance singleton
    static let shared = VehicleValuationService()
    
    // MARK: - Propriétés
    
    private let dataManager = DataManager.shared
    
    // MARK: - Méthodes publiques
    
    func calculateVehicleValue(_ vehicle: Vehicle) -> Double {
        // Prix de base selon l'année et le modèle
        var baseValue = getBaseValue(for: vehicle)
        
        // Ajustements selon le kilométrage
        baseValue *= getMileageMultiplier(for: vehicle)
        
        // Ajustements selon l'état
        baseValue *= getConditionMultiplier(for: vehicle)
        
        // Ajustements selon les options
        baseValue *= getOptionsMultiplier(for: vehicle)
        
        return baseValue
    }
    
    func getMarketValue(for vehicle: Vehicle) -> Double {
        // Dans une vraie application, on appellerait une API externe
        // Pour l'instant, on utilise une estimation simple
        return calculateVehicleValue(vehicle)
    }
    
    func getDepreciationRate(for vehicle: Vehicle) -> Double {
        let age = Calendar.current.dateComponents([.year], from: vehicle.purchaseDate, to: Date()).year ?? 0
        return calculateDepreciationRate(age: age)
    }
    
    // MARK: - Méthodes privées
    
    private func getBaseValue(for vehicle: Vehicle) -> Double {
        // Dans une vraie application, on utiliserait une base de données de prix
        // Pour l'instant, on utilise des valeurs approximatives
        let baseValues: [String: Double] = [
            "Renault": 15000,
            "Peugeot": 16000,
            "Citroën": 14000,
            "Volkswagen": 18000,
            "BMW": 25000,
            "Mercedes": 28000,
            "Audi": 26000
        ]
        
        return baseValues[vehicle.brand] ?? 15000
    }
    
    private func getMileageMultiplier(for vehicle: Vehicle) -> Double {
        let averageYearlyMileage: Double = 15000 // km par an
        let age = Calendar.current.dateComponents([.year], from: vehicle.purchaseDate, to: Date()).year ?? 1
        let expectedMileage = averageYearlyMileage * Double(age)
        
        let mileageRatio = vehicle.mileage / expectedMileage
        
        switch mileageRatio {
        case 0..<0.5:
            return 1.2
        case 0.5..<0.8:
            return 1.1
        case 0.8..<1.2:
            return 1.0
        case 1.2..<1.5:
            return 0.9
        default:
            return 0.8
        }
    }
    
    private func getConditionMultiplier(for vehicle: Vehicle) -> Double {
        // Dans une vraie application, on prendrait en compte l'historique des maintenances
        let maintenances = dataManager.getMaintenances(for: vehicle.id)
        let recentMaintenances = maintenances.filter { Calendar.current.isDateInLastMonth($0.date) }
        
        if recentMaintenances.isEmpty {
            return 0.9
        }
        
        return 1.0
    }
    
    private func getOptionsMultiplier(for vehicle: Vehicle) -> Double {
        // Dans une vraie application, on prendrait en compte les options du véhicule
        return 1.0
    }
    
    private func calculateDepreciationRate(age: Int) -> Double {
        // Taux de dépréciation approximatif par année
        switch age {
        case 0:
            return 1.0
        case 1:
            return 0.85
        case 2:
            return 0.70
        case 3:
            return 0.60
        case 4:
            return 0.50
        default:
            return 0.40
        }
    }
} 