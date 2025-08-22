import Foundation
import SwiftUI
import CloudKit

// ViewModel pour gérer les dépenses
public class ExpensesViewModel: ObservableObject {
    // Liste des dépenses, observable par la vue
    @Published var expenses: [Expense] = []
    // Texte de recherche
    @Published var searchText: String = ""
    // Filtre sélectionné
    @Published var selectedFilter: ExpenseFilter = .all
    // Filtrage par période (exemple)
    @Published var selectedTimeRange: TimeRange = .month
    @Published var isSyncingCloud = false
    @Published var cloudError: String? = nil
    // Filtres avancés
    @Published var selectedVehicleId: UUID? = nil
    @Published var minAmount: Double? = nil
    @Published var maxAmount: Double? = nil
    
    // Référence vers MaintenanceViewModel pour synchronisation bidirectionnelle
    weak var maintenanceViewModel: MaintenanceViewModel?
    
    // Référence vers VehiclesViewModel pour obtenir les noms des véhicules
    weak var vehiclesViewModel: VehiclesViewModel?
    
    private let persistenceFilename = "expenses.json"

    // Initialisation : chargement des dépenses sauvegardées
    public init() {
        loadExpenses()
                    syncFromCloud() // 🔧 Sync Cloud temporairement désactivé pour publication V1
    }
    
    /// Charge les dépenses depuis le stockage local
    private func loadExpenses() {
        if let loadedExpenses = PersistenceService.load([Expense].self, from: persistenceFilename) {
            expenses = loadedExpenses
        } else {
            expenses = []
        }
    }
    
    /// Sauvegarde les dépenses dans le stockage local
    private func saveExpenses() {
        PersistenceService.save(expenses, to: persistenceFilename)
    }
    
    /// Configure les références pour la synchronisation
    func configure(with maintenanceViewModel: MaintenanceViewModel, vehiclesViewModel: VehiclesViewModel) {
        self.maintenanceViewModel = maintenanceViewModel
        self.vehiclesViewModel = vehiclesViewModel
    }

    // Ajoute une dépense à la liste
    func addExpense(_ expense: Expense) {
        withAnimation {
            expenses.append(expense)
        }
        saveExpenses()
        
        // Synchronisation automatique : si c'est une dépense maintenance, créer une maintenance
        if expense.category == .maintenance {
            syncMaintenanceFromExpense(expense)
        }
        
        CloudKitExpenseService.shared.saveExpense(expense) { result in
            if case .failure(let error) = result {
                self.cloudError = error.localizedDescription
            }
        }
        // Planification d'une notification de rappel 1 mois après la dépense
        NotificationService.requestAuthorization { granted in
            if granted {
                let reminderDate = Calendar.current.date(byAdding: .month, value: 1, to: expense.date) ?? Date()
                NotificationService.scheduleNotification(
                    title: "Rappel de dépense",
                    body: "Pense à vérifier tes dépenses ce mois-ci.",
                    date: reminderDate,
                    identifier: "expense_reminder_\(expense.id)"
                )
            }
        }
    }
    
    /// Ajoute une dépense depuis une maintenance (évite la boucle infinie)
    internal func addExpenseFromMaintenance(_ expense: Expense) {
        withAnimation {
            expenses.append(expense)
        }
        saveExpenses()
        CloudKitExpenseService.shared.saveExpense(expense) { result in
            if case .failure(let error) = result {
                self.cloudError = error.localizedDescription
            }
        }
    }

    // Modifier une dépense existante
    func editExpense(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            let oldExpense = expenses[index]
            expenses[index] = expense
            saveExpenses()
            
            // Synchronisation automatique : si c'est une dépense maintenance, mettre à jour la maintenance
            if expense.category == .maintenance {
                syncMaintenanceFromExpense(expense)
            } else if oldExpense.category == .maintenance && expense.category != .maintenance {
                // Si la catégorie change de maintenance vers autre chose, supprimer la maintenance
                deleteMaintenanceFromExpense(expense.id)
            }
            
            CloudKitExpenseService.shared.saveExpense(expense) { result in
                if case .failure(let error) = result {
                    self.cloudError = error.localizedDescription
                }
            }
        }
    }
    
    /// Met à jour une dépense depuis une maintenance (évite la boucle infinie)
    internal func updateExpenseFromMaintenance(_ expense: Expense) {
        if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
            expenses[index] = expense
            saveExpenses()
            CloudKitExpenseService.shared.saveExpense(expense) { result in
                if case .failure(let error) = result {
                    self.cloudError = error.localizedDescription
                }
            }
        }
    }

    // Supprimer une dépense
    func deleteExpense(_ expense: Expense) {
        withAnimation {
            expenses.removeAll { $0.id == expense.id }
        }
        saveExpenses()
        
        // Synchronisation automatique : si c'est une dépense maintenance, supprimer la maintenance
        if expense.category == .maintenance {
            deleteMaintenanceFromExpense(expense.id)
        }
        
        CloudKitExpenseService.shared.deleteExpense(expense) { result in
            if case .failure(let error) = result {
                self.cloudError = error.localizedDescription
            }
        }
    }
    
    /// Supprime une dépense depuis une maintenance (évite la boucle infinie)
    internal func deleteExpenseFromMaintenance(_ expenseId: UUID) {
        withAnimation {
            expenses.removeAll { $0.id == expenseId }
        }
        saveExpenses()
        // Pas de sync vers CloudKit car c'est déjà fait par la maintenance
    }

    // Synchronise les dépenses depuis CloudKit
    func syncFromCloud() {
        isSyncingCloud = true
        CloudKitExpenseService.shared.fetchExpenses { result in
            self.isSyncingCloud = false
            switch result {
            case .success(let cloudExpenses):
                // Fusion intelligente : garder les données locales et ajouter celles du cloud qui ne sont pas déjà présentes
                let localIds = Set(self.expenses.map { $0.id })
                let newCloudExpenses = cloudExpenses.filter { !localIds.contains($0.id) }
                
                self.expenses.append(contentsOf: newCloudExpenses)
                self.saveExpenses()
                
                // Synchroniser les maintenances depuis les dépenses maintenance chargées
                self.syncAllMaintenancesFromExpenses()
            case .failure(let error):
                self.cloudError = error.localizedDescription
                print("Erreur de synchronisation CloudKit:", error.localizedDescription)
            }
        }
    }

    // Filtrage par période (mois, année, etc.)
    var filteredExpenses: [Expense] {
        let calendar = Calendar.current
        let now = Date()
        let filteredByPeriod: [Expense] = expenses.filter { expense in
            switch selectedTimeRange {
            case .month:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .month)
            case .year:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .year)
            case .week:
                return calendar.isDate(expense.date, equalTo: now, toGranularity: .weekOfYear)
            case .quarter:
                if let quarter = calendar.dateInterval(of: .quarter, for: now) {
                    return quarter.contains(expense.date)
                }
                return false
            case .all:
                return true
            }
        }
        return filteredByPeriod.filter { expense in
            (searchText.isEmpty || expense.description.localizedCaseInsensitiveContains(searchText)) &&
            (selectedFilter == .all || expense.category.rawValue == selectedFilter.rawValue) &&
            (selectedVehicleId == nil || expense.vehicleId == selectedVehicleId) &&
            (minAmount == nil || expense.amount >= minAmount!) &&
            (maxAmount == nil || expense.amount <= maxAmount!)
        }
    }
    
    // MARK: - Synchronisation privée
    
    /// Synchronise une maintenance depuis une dépense maintenance
    private func syncMaintenanceFromExpense(_ expense: Expense) {
        guard let maintenanceViewModel = maintenanceViewModel,
              let vehiclesViewModel = vehiclesViewModel else { return }
        
        // Obtenir le nom du véhicule depuis son ID
        let vehicleName = vehiclesViewModel.vehicles.first(where: { $0.id == expense.vehicleId })?.brand ?? "Véhicule inconnu"
        
        maintenanceViewModel.syncMaintenanceFromExpense(expense, vehicleName: vehicleName)
    }
    
    /// Supprime une maintenance depuis une dépense supprimée
    private func deleteMaintenanceFromExpense(_ expenseId: UUID) {
        guard let maintenanceViewModel = maintenanceViewModel else { return }
        maintenanceViewModel.deleteMaintenanceFromExpense(expenseId)
    }
    
    /// Synchronise toutes les maintenances depuis les dépenses au chargement
    private func syncAllMaintenancesFromExpenses() {
        let maintenanceExpenses = expenses.filter { $0.category == .maintenance }
        for expense in maintenanceExpenses {
            syncMaintenanceFromExpense(expense)
        }
    }
}

// Explications pédagogiques :
// - Les dépenses sont sauvegardées automatiquement dans un fichier JSON à chaque modification.
// - Le ViewModel expose filteredExpenses pour la recherche et le filtrage.
// - La logique métier (ajout, filtrage, persistance) est centralisée ici.
// - withAnimation permet d'animer l'ajout et la suppression dans la liste SwiftUI.
// - Chaque modification locale est synchronisée avec CloudKit.
// - syncFromCloud permet de charger les dépenses iCloud au démarrage ou sur demande.
// - cloudError permet d'afficher une erreur à l'utilisateur si besoin.
// - selectedVehicleId permet de filtrer par véhicule.
// - minAmount et maxAmount permettent de filtrer par plage de montant.
// - filteredExpenses applique tous les filtres combinés.
// - La synchronisation bidirectionnelle évite les boucles infinies avec des méthodes internes. 