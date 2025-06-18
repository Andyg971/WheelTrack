import Foundation
import UserNotifications

class RentalService: ObservableObject {
    static let shared = RentalService()
    
    @Published var rentalContracts: [RentalContract] = []
    
    private let persistenceFilename = "rental_contracts.json"
    
    private init() {
        loadRentalContracts()
        requestNotificationPermission()
    }
    
    // MARK: - Persistance
    
    private func loadRentalContracts() {
        if let loadedContracts = PersistenceService.load([RentalContract].self, from: persistenceFilename) {
            rentalContracts = loadedContracts
        } else {
            rentalContracts = []
        }
    }
    
    private func saveRentalContracts() {
        PersistenceService.save(rentalContracts, to: persistenceFilename)
    }
    
    // MARK: - Opérations CRUD
    
    func addRentalContract(_ contract: RentalContract) {
        rentalContracts.append(contract)
        saveRentalContracts()
        scheduleNotification(for: contract)
        
        // ✅ Notification synchrone immédiate
        objectWillChange.send()
    }
    
    func updateRentalContract(_ contract: RentalContract) {
        if let index = rentalContracts.firstIndex(where: { $0.id == contract.id }) {
            // Annuler l'ancienne notification
            cancelNotification(for: rentalContracts[index])
            
            // Mettre à jour le contrat
            rentalContracts[index] = contract
            saveRentalContracts()
            
            // Programmer la nouvelle notification
            scheduleNotification(for: contract)
            
            // ✅ Notification synchrone immédiate
            objectWillChange.send()
        }
    }
    
    func deleteRentalContract(_ contract: RentalContract) {
        cancelNotification(for: contract)
        rentalContracts.removeAll { $0.id == contract.id }
        saveRentalContracts()
        
        // ✅ Notification synchrone immédiate
        objectWillChange.send()
    }
    
    // MARK: - Gestion des contrats préremplis
    
    /// Crée un contrat prérempli pour un véhicule disponible à la location
    func createPrefilledContract(for vehicle: Vehicle) -> RentalContract? {
        guard vehicle.isAvailableForRent,
              let rentalPrice = vehicle.rentalPrice,
              rentalPrice > 0 else {
            return nil
        }
        
        // Dates par défaut : disponible à partir d'aujourd'hui pour 7 jours
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: vehicle.minimumRentalDays ?? 7, to: startDate) ?? Date()
        
        // Rapport d'état prérempli
        let conditionReport = "Véhicule en bon état général. État détaillé à compléter lors de la remise des clés."
        
        return RentalContract(
            vehicleId: vehicle.id,
            renterName: "", // À compléter par l'utilisateur
            startDate: startDate,
            endDate: endDate,
            pricePerDay: rentalPrice,
            conditionReport: conditionReport,
            depositAmount: vehicle.depositAmount ?? 0.0
        )
    }
    
    /// Vérifie si un véhicule a déjà un contrat prérempli
    func hasPrefilledContract(for vehicleId: UUID) -> Bool {
        return rentalContracts.contains { contract in
            contract.vehicleId == vehicleId && 
            contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
    
    /// Crée automatiquement un contrat prérempli pour un véhicule mis en location
    func autoCreatePrefilledContract(for vehicle: Vehicle) {
        // Ne créer un contrat prérempli que si :
        // 1. Le véhicule est disponible pour location
        // 2. Il n'y a pas déjà de contrat prérempli
        // 3. Il n'y a pas de contrats actifs ou à venir
        guard vehicle.isAvailableForRent,
              !hasPrefilledContract(for: vehicle.id),
              !hasActiveOrUpcomingContracts(for: vehicle.id) else {
            return
        }
        
        if let prefilledContract = createPrefilledContract(for: vehicle) {
            rentalContracts.append(prefilledContract)
            saveRentalContracts()
            
            // ✅ Notification synchrone immédiate pour mise à jour instantanée
            objectWillChange.send()
        }
    }
    
    /// Vérifie si un véhicule a des contrats actifs ou à venir
    private func hasActiveOrUpcomingContracts(for vehicleId: UUID) -> Bool {
        let now = Date()
        return rentalContracts.contains { contract in
            contract.vehicleId == vehicleId &&
            !contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty &&
            contract.endDate >= now
        }
    }
    
    // MARK: - Méthodes de recherche
    
    func getRentalContracts(for vehicleId: UUID) -> [RentalContract] {
        return rentalContracts.filter { $0.vehicleId == vehicleId }
    }
    
    func getActiveContracts() -> [RentalContract] {
        return rentalContracts.filter { $0.isActive() }
    }
    
    func getUpcomingContracts() -> [RentalContract] {
        let now = Date()
        return rentalContracts.filter { $0.startDate > now }
    }
    
    func getExpiredContracts() -> [RentalContract] {
        return rentalContracts.filter { $0.isExpired() }
    }
    
    // MARK: - Validation
    
    func isVehicleAvailable(vehicleId: UUID, startDate: Date, endDate: Date, excludingContractId: UUID? = nil) -> Bool {
        let overlappingContracts = rentalContracts.filter { contract in
            guard contract.vehicleId == vehicleId else { return false }
            
            // Exclure le contrat en cours de modification
            if let excludingId = excludingContractId, contract.id == excludingId {
                return false
            }
            
            // Vérifier le chevauchement de dates
            return !(endDate <= contract.startDate || startDate >= contract.endDate)
        }
        
        return overlappingContracts.isEmpty
    }
    
    func validateContract(_ contract: RentalContract) -> ValidationResult {
        // Vérifier les dates
        guard contract.startDate < contract.endDate else {
            return .failure("La date de début doit être antérieure à la date de fin")
        }
        
        // Vérifier la disponibilité du véhicule
        guard isVehicleAvailable(vehicleId: contract.vehicleId, startDate: contract.startDate, endDate: contract.endDate, excludingContractId: contract.id) else {
            return .failure("Le véhicule n'est pas disponible pour cette période")
        }
        
        // Vérifier le prix
        guard contract.pricePerDay > 0 else {
            return .failure("Le prix journalier doit être supérieur à 0")
        }
        
        // Vérifier le nom du locataire (sauf pour les contrats préremplis)
        if !contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty {
            // Pour les contrats avec locataire, effectuer toutes les validations
        }
        
        return .success
    }
    
    // MARK: - Notifications
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Erreur lors de la demande d'autorisation de notification: \(error)")
            }
        }
    }
    
    private func scheduleNotification(for contract: RentalContract) {
        let center = UNUserNotificationCenter.current()
        
        // Notification 1 jour avant la fin du contrat
        let content = UNMutableNotificationContent()
        content.title = "Fin de location proche"
        content.body = "Le contrat de location de \(contract.renterName) se termine demain"
        content.sound = .default
        
        // Calculer la date de notification (1 jour avant la fin)
        let calendar = Calendar.current
        guard let notificationDate = calendar.date(byAdding: .day, value: -1, to: contract.endDate) else {
            return
        }
        
        // Ne programmer que si la date est dans le futur
        guard notificationDate > Date() else { return }
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "rental_\(contract.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Erreur lors de la programmation de la notification: \(error)")
            }
        }
    }
    
    private func cancelNotification(for contract: RentalContract) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["rental_\(contract.id.uuidString)"])
    }
}

enum ValidationResult {
    case success
    case failure(String)
    
    var isValid: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .success:
            return nil
        case .failure(let message):
            return message
        }
    }
} 