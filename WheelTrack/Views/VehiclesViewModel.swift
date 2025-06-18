import Foundation
import Combine

/// ViewModel pour la gestion des véhicules (MVVM)
public class VehiclesViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []
    @Published var searchText: String = ""
    
    private let persistenceFilename = "vehicles.json"
    private var rentalService: RentalService { RentalService.shared }

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
        
        // Si le véhicule est disponible pour location, créer automatiquement un contrat prérempli
        if vehicle.isAvailableForRent && vehicle.rentalPrice != nil && vehicle.rentalPrice! > 0 {
            // ✅ Exécution immédiate pour une meilleure réactivité
            rentalService.autoCreatePrefilledContract(for: vehicle)
        }
    }

    /// Supprime un véhicule
    func deleteVehicle(_ vehicle: Vehicle) {
        vehicles.removeAll { $0.id == vehicle.id }
        saveVehicles()
    }

    /// Modifie un véhicule existant
    func updateVehicle(_ vehicle: Vehicle) {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            let oldVehicle = vehicles[index]
            vehicles[index] = vehicle
            saveVehicles()
            
            // Vérifier si le véhicule vient d'être activé pour la location
            let wasNotAvailable = !oldVehicle.isAvailableForRent || oldVehicle.rentalPrice == nil || oldVehicle.rentalPrice! <= 0
            let isNowAvailable = vehicle.isAvailableForRent && vehicle.rentalPrice != nil && vehicle.rentalPrice! > 0
            
            if wasNotAvailable && isNowAvailable {
                // Le véhicule vient d'être activé pour la location, créer un contrat prérempli
                // ✅ Exécution immédiate pour une meilleure réactivité
                rentalService.autoCreatePrefilledContract(for: vehicle)
            }
        }
    }

    /// Liste filtrée selon la recherche
    var filteredVehicles: [Vehicle] {
        vehicles.filter { v in
            searchText.isEmpty || v.brand.localizedCaseInsensitiveContains(searchText) || v.model.localizedCaseInsensitiveContains(searchText) || v.licensePlate.localizedCaseInsensitiveContains(searchText)
        }
    }
} 