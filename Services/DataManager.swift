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
    private var rentals: [RentalContract] = []
    
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
           let decoded = try? JSONDecoder().decode([RentalContract].self, from: data) {
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
    
    func updateExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            saveData()
        }
    }
    
    func deleteExpense(_ expense: Expense) {
        expenses.removeAll { $0.id == expense.id }
        saveData()
    }
    
    func getExpenses(for vehicleId: UUID) -> [Expense] {
        return expenses.filter { $0.vehicleId == vehicleId }
    }
    
    func getAllExpenses() -> [Expense] {
        return expenses
    }
    
    // MARK: - Méthodes pour les maintenances
    
    func addMaintenance(_ maintenance: Maintenance) {
        maintenances.append(maintenance)
        saveData()
    }
    
    func updateMaintenance(_ maintenance: Maintenance) {
        if let index = maintenances.firstIndex(where: { $0.id == maintenance.id }) {
            maintenances[index] = maintenance
            saveData()
        }
    }
    
    func deleteMaintenance(_ maintenance: Maintenance) {
        maintenances.removeAll { $0.id == maintenance.id }
        saveData()
    }
    
    func getMaintenances(for vehicleId: UUID) -> [Maintenance] {
        return maintenances.filter { $0.vehicleId == vehicleId }
    }
    
    func getAllMaintenances() -> [Maintenance] {
        return maintenances
    }
    
    // MARK: - Méthodes pour les garages
    
    func addGarage(_ garage: Garage) {
        garages.append(garage)
        saveData()
    }
    
    func updateGarage(_ garage: Garage) {
        if let index = garages.firstIndex(where: { $0.id == garage.id }) {
            garages[index] = garage
            saveData()
        }
    }
    
    func deleteGarage(_ garage: Garage) {
        garages.removeAll { $0.id == garage.id }
        saveData()
    }
    
    func getGarage(id: UUID) -> Garage? {
        return garages.first { $0.id == id }
    }
    
    func getAllGarages() -> [Garage] {
        return garages
    }
    
    // MARK: - Méthodes pour les locations
    
    func addRental(_ rental: RentalContract) {
        rentals.append(rental)
        saveData()
    }
    
    func getRentals(for vehicleId: UUID) -> [RentalContract] {
        return rentals.filter { $0.vehicleId == vehicleId }
    }
    
    func updateRental(_ rental: RentalContract) {
        if let index = rentals.firstIndex(where: { $0.id == rental.id }) {
            rentals[index] = rental
            saveData()
        }
    }
    
    func deleteRental(_ rental: RentalContract) {
        rentals.removeAll { $0.id == rental.id }
        saveData()
    }
    
    func getAllRentals() -> [RentalContract] {
        return rentals
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