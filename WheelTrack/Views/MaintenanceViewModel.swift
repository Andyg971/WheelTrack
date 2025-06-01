import Foundation
import Combine

/// ViewModel pour la gestion des maintenances (MVVM)
class MaintenanceViewModel: ObservableObject {
    @Published var maintenances: [Maintenance] = []
    @Published var searchText: String = ""
    @Published var selectedVehicle: String = "Tous les véhicules"
    
    // Référence vers ExpensesViewModel pour synchronisation bidirectionnelle
    weak var expensesViewModel: ExpensesViewModel?

    // Référence vers VehiclesViewModel pour obtenir les véhicules
    weak var vehiclesViewModel: VehiclesViewModel?
    
    private let persistenceFilename = "maintenances.json"

    /// Initialisation : charge les maintenances sauvegardées
    init() {
        loadMaintenances()
    }
    
    /// Charge les maintenances depuis le stockage local
    private func loadMaintenances() {
        if let loadedMaintenances = PersistenceService.load([Maintenance].self, from: persistenceFilename) {
            maintenances = loadedMaintenances
        } else {
            maintenances = []
        }
    }
    
    /// Sauvegarde les maintenances dans le stockage local
    private func saveMaintenances() {
        PersistenceService.save(maintenances, to: persistenceFilename)
    }
    
    /// Configure la référence vers ExpensesViewModel pour la synchronisation
    func configure(with expensesViewModel: ExpensesViewModel, vehiclesViewModel: VehiclesViewModel? = nil) {
        self.expensesViewModel = expensesViewModel
        self.vehiclesViewModel = vehiclesViewModel
    }

    /// Retourne la liste des véhicules présents dans les maintenances
    var vehicles: [String] {
        Array(Set(maintenances.map { $0.vehicule })).sorted()
    }

    /// Ajoute une maintenance et crée automatiquement une dépense correspondante
    func addMaintenance(_ maintenance: Maintenance) {
        maintenances.append(maintenance)
        saveMaintenances()
        
        // Synchronisation automatique : créer une dépense maintenance
        createExpenseFromMaintenance(maintenance)
        
        // Planification d'une notification de rappel 6 mois après la maintenance
        NotificationService.requestAuthorization { granted in
            if granted {
                let reminderDate = Calendar.current.date(byAdding: .month, value: 6, to: maintenance.date) ?? Date()
                NotificationService.scheduleNotification(
                    title: "Rappel de maintenance",
                    body: "Pense à planifier ta prochaine maintenance.",
                    date: reminderDate,
                    identifier: "maintenance_reminder_\(maintenance.id)"
                )
            }
        }
    }

    /// Supprime une maintenance et la dépense correspondante
    func deleteMaintenance(_ maintenance: Maintenance) {
        maintenances.removeAll { $0.id == maintenance.id }
        saveMaintenances()
        
        // Synchronisation automatique : supprimer la dépense correspondante
        deleteExpenseFromMaintenance(maintenance)
    }

    /// Modifie une maintenance existante et met à jour la dépense correspondante
    func updateMaintenance(_ maintenance: Maintenance) {
        if let index = maintenances.firstIndex(where: { $0.id == maintenance.id }) {
            let oldMaintenance = maintenances[index]
            maintenances[index] = maintenance
            saveMaintenances()
            
            // Synchronisation automatique : mettre à jour la dépense correspondante
            updateExpenseFromMaintenance(oldMaintenance, newMaintenance: maintenance)
        }
    }
    
    /// Synchronise depuis une dépense maintenance (appelé par ExpensesViewModel)
    func syncMaintenanceFromExpense(_ expense: Expense, vehicleName: String) {
        // Vérifier si une maintenance avec cet ID existe déjà
        if let existingIndex = maintenances.firstIndex(where: { $0.id.uuidString == expense.id.uuidString }) {
            // Mettre à jour la maintenance existante
            var updatedMaintenance = maintenances[existingIndex]
            updatedMaintenance.titre = expense.description
            updatedMaintenance.date = expense.date
            updatedMaintenance.cout = expense.amount
            updatedMaintenance.vehicule = vehicleName
            maintenances[existingIndex] = updatedMaintenance
            saveMaintenances()
        } else {
            // Créer une nouvelle maintenance depuis la dépense
            let newMaintenance = Maintenance(
                id: expense.id,
                titre: expense.description,
                date: expense.date,
                cout: expense.amount,
                kilometrage: Int(expense.mileage ?? 0),
                description: expense.notes ?? "Maintenance automatique",
                garage: "Non spécifié",
                vehicule: vehicleName
            )
            maintenances.append(newMaintenance)
            saveMaintenances()
        }
    }
    
    /// Supprime une maintenance synchronisée depuis une dépense
    func deleteMaintenanceFromExpense(_ expenseId: UUID) {
        maintenances.removeAll { $0.id == expenseId }
        saveMaintenances()
    }

    /// Liste filtrée selon recherche et véhicule
    var filteredMaintenances: [Maintenance] {
        maintenances.filter { m in
            (searchText.isEmpty || m.titre.localizedCaseInsensitiveContains(searchText) || m.vehicule.localizedCaseInsensitiveContains(searchText)) &&
            (selectedVehicle == "Tous les véhicules" || m.vehicule == selectedVehicle)
        }
    }
    
    // MARK: - Synchronisation privée
    
    /// Crée une dépense depuis une maintenance
    private func createExpenseFromMaintenance(_ maintenance: Maintenance) {
        guard let expensesViewModel = expensesViewModel else { return }
        
        // Trouver l'ID du véhicule depuis le nom
        let vehicleId = findVehicleId(for: maintenance.vehicule) ?? UUID()
        
        let expense = Expense(
            id: maintenance.id,
            vehicleId: vehicleId,
            date: maintenance.date,
            amount: maintenance.cout,
            category: .maintenance,
            description: maintenance.titre,
            mileage: Double(maintenance.kilometrage),
            notes: maintenance.description
        )
        
        expensesViewModel.addExpenseFromMaintenance(expense)
    }
    
    /// Met à jour une dépense depuis une maintenance modifiée
    private func updateExpenseFromMaintenance(_ oldMaintenance: Maintenance, newMaintenance: Maintenance) {
        guard let expensesViewModel = expensesViewModel else { return }
        
        let vehicleId = findVehicleId(for: newMaintenance.vehicule) ?? UUID()
        
        let updatedExpense = Expense(
            id: newMaintenance.id,
            vehicleId: vehicleId,
            date: newMaintenance.date,
            amount: newMaintenance.cout,
            category: .maintenance,
            description: newMaintenance.titre,
            mileage: Double(newMaintenance.kilometrage),
            notes: newMaintenance.description
        )
        
        expensesViewModel.updateExpenseFromMaintenance(updatedExpense)
    }
    
    /// Supprime une dépense depuis une maintenance supprimée
    private func deleteExpenseFromMaintenance(_ maintenance: Maintenance) {
        guard let expensesViewModel = expensesViewModel else { return }
        expensesViewModel.deleteExpenseFromMaintenance(maintenance.id)
    }
    
    /// Trouve l'ID d'un véhicule depuis son nom (temporaire, à améliorer avec une vraie référence)
    private func findVehicleId(for vehicleName: String) -> UUID? {
        // Utilise la référence aux véhicules pour trouver le bon ID
        guard let vehiclesViewModel = vehiclesViewModel else {
            // Fallback vers un UUID temporaire si pas de référence
            return UUID()
        }
        
        // Cherche le véhicule par nom de marque ou modèle
        if let vehicle = vehiclesViewModel.vehicles.first(where: { vehicle in
            vehicle.brand.contains(vehicleName) || 
            vehicleName.contains(vehicle.brand) ||
            vehicleName.contains(vehicle.model)
        }) {
            return vehicle.id
        }
        
        // Si aucun véhicule trouvé, retourne le premier disponible ou un UUID temporaire
        return vehiclesViewModel.vehicles.first?.id ?? UUID()
    }
} 