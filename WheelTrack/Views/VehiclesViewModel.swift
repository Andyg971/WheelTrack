import Foundation
import Combine

/// ViewModel pour la gestion des véhicules (MVVM)
public class VehiclesViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var searchText: String = ""
    
    private let persistenceFilename = "vehicles.json"

    /// Initialisation : charge les véhicules sauvegardés
    init() {
        loadVehicles()
    }
    
    /// Charge les véhicules depuis le stockage local
    private func loadVehicles() {
        if let loadedVehicles = PersistenceService.load([Vehicle].self, from: persistenceFilename) {
            vehicles = loadedVehicles
        } else {
            vehicles = []
        }
    }
    
    /// Sauvegarde les véhicules dans le stockage local
    private func saveVehicles() {
        PersistenceService.save(vehicles, to: persistenceFilename)
    }

    /// Ajoute un véhicule
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
        saveVehicles()
    }

    /// Supprime un véhicule
    func deleteVehicle(_ vehicle: Vehicle) {
        vehicles.removeAll { $0.id == vehicle.id }
        saveVehicles()
    }

    /// Modifie un véhicule existant
    func updateVehicle(_ vehicle: Vehicle) {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index] = vehicle
            saveVehicles()
        }
    }

    /// Liste filtrée selon la recherche
    var filteredVehicles: [Vehicle] {
        vehicles.filter { v in
            searchText.isEmpty || v.brand.localizedCaseInsensitiveContains(searchText) || v.model.localizedCaseInsensitiveContains(searchText) || v.licensePlate.localizedCaseInsensitiveContains(searchText)
        }
    }
} 