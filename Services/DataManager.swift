import Foundation

class DataManager {
    // Instance singleton
    static let shared = DataManager()
    
    // Clés pour UserDefaults
    private enum StorageKeys {
        static let vehicles = "vehicles"
        static let expenses = "expenses"
        static let maintenances = "maintenances"
        static let garages = "garages"
        static let rentals = "rentals"
    }
    
    // MARK: - Propriétés
    
    private var vehicles: [Vehicle] = []
    private var expenses: [Expense] = []
    private var maintenances: [Maintenance] = []
    private var garages: [Garage] = []
    private var rentals: [RentalInfo] = []
    
    // MARK: - Initialisation
    
    private init() {
        loadData()
    }
    
    // MARK: - Méthodes de chargement
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: StorageKeys.vehicles),
           let decoded = try? JSONDecoder().decode([Vehicle].self, from: data) {
            vehicles = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: StorageKeys.expenses),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: StorageKeys.maintenances),
           let decoded = try? JSONDecoder().decode([Maintenance].self, from: data) {
            maintenances = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: StorageKeys.garages),
           let decoded = try? JSONDecoder().decode([Garage].self, from: data) {
            garages = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: StorageKeys.rentals),
           let decoded = try? JSONDecoder().decode([RentalInfo].self, from: data) {
            rentals = decoded
        }
    }
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(vehicles) {
            UserDefaults.standard.set(encoded, forKey: StorageKeys.vehicles)
        }
        
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: StorageKeys.expenses)
        }
        
        if let encoded = try? JSONEncoder().encode(maintenances) {
            UserDefaults.standard.set(encoded, forKey: StorageKeys.maintenances)
        }
        
        if let encoded = try? JSONEncoder().encode(garages) {
            UserDefaults.standard.set(encoded, forKey: StorageKeys.garages)
        }
        
        if let encoded = try? JSONEncoder().encode(rentals) {
            UserDefaults.standard.set(encoded, forKey: StorageKeys.rentals)
        }
    }
    
    // MARK: - Méthodes pour les véhicules
    
    func addVehicle(_ vehicle: Vehicle) {
        vehicles.append(vehicle)
        saveData()
    }
    
    func updateVehicle(_ vehicle: Vehicle) {
        if let index = vehicles.firstIndex(where: { $0.id == vehicle.id }) {
            vehicles[index] = vehicle
            saveData()
        }
    }
    
    func deleteVehicle(_ vehicle: Vehicle) {
        vehicles.removeAll { $0.id == vehicle.id }
        saveData()
    }
    
    func getVehicle(id: UUID) -> Vehicle? {
        return vehicles.first { $0.id == id }
    }
    
    func getAllVehicles() -> [Vehicle] {
        return vehicles
    }
    
    // MARK: - Méthodes pour les dépenses
    
    func addExpense(_ expense: Expense) {
        expenses.append(expense)
        saveData()
    }
    
    func getExpenses(for vehicleId: UUID) -> [Expense] {
        return expenses.filter { $0.vehicleId == vehicleId }
    }
    
    // MARK: - Méthodes pour les maintenances
    
    func addMaintenance(_ maintenance: Maintenance) {
        maintenances.append(maintenance)
        saveData()
    }
    
    func getMaintenances(for vehicleId: UUID) -> [Maintenance] {
        return maintenances.filter { $0.vehicleId == vehicleId }
    }
    
    // MARK: - Méthodes pour les garages
    
    func addGarage(_ garage: Garage) {
        garages.append(garage)
        saveData()
    }
    
    func getGarage(id: UUID) -> Garage? {
        return garages.first { $0.id == id }
    }
    
    func getAllGarages() -> [Garage] {
        return garages
    }
    
    // MARK: - Méthodes pour les locations
    
    func addRental(_ rental: RentalInfo) {
        rentals.append(rental)
        saveData()
    }
    
    func getRentals(for vehicleId: UUID) -> [RentalInfo] {
        return rentals.filter { $0.vehicleId == vehicleId }
    }
    
    // MARK: - Méthodes utilitaires
    
    func clearAllData() {
        vehicles.removeAll()
        expenses.removeAll()
        maintenances.removeAll()
        garages.removeAll()
        rentals.removeAll()
        saveData()
    }
} 