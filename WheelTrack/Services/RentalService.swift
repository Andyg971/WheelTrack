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
        let calendar = Calendar.current
        let now = Date()
        
        // 🚀 NOTIFICATION 1 : Début de location demain (pour préparer le véhicule)
        if let startTomorrowDate = calendar.date(byAdding: .day, value: -1, to: contract.startDate),
           startTomorrowDate > now {
            
            let content = UNMutableNotificationContent()
            content.title = L(CommonTranslations.rentalStartsTomorrow)
            content.body = "\(contract.renterName) \(L(CommonTranslations.rentalStartsTomorrowBody))"
            content.sound = .default
            
            var dateComponents = calendar.dateComponents([.year, .month, .day], from: startTomorrowDate)
            dateComponents.hour = 18 // 18h la veille
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: "rental_start_tomorrow_\(contract.id.uuidString)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
        
        // 🎯 NOTIFICATION 2 : Début de location dans 2h (pour être prêt)
        if let startSoonDate = calendar.date(byAdding: .hour, value: -2, to: contract.startDate),
           startSoonDate > now {
            
            let content = UNMutableNotificationContent()
            content.title = L(CommonTranslations.rentalStartsIn2Hours)
            content.body = "\(contract.renterName) \(L(CommonTranslations.rentalStartsIn2HoursBody))"
            content.sound = .default
            
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startSoonDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "rental_start_soon_\(contract.id.uuidString)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
        
        // ⚠️ NOTIFICATION 3 : Fin de location AUJOURD'HUI (pour récupérer)
        let endTodayComponents = calendar.dateComponents([.year, .month, .day], from: contract.endDate)
        var endTodayNotif = endTodayComponents
        endTodayNotif.hour = 9 // 9h le jour J
        endTodayNotif.minute = 0
        
        if let endTodayDate = calendar.date(from: endTodayNotif),
           endTodayDate > now {
            
            let content = UNMutableNotificationContent()
            content.title = L(CommonTranslations.rentalEndsTodayTitle)
            content.body = "\(contract.renterName) \(L(CommonTranslations.rentalEndsTodayBody))"
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: endTodayNotif, repeats: false)
            let request = UNNotificationRequest(
                identifier: "rental_end_today_\(contract.id.uuidString)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
        
        // 📋 NOTIFICATION 4 : Fin de location demain (l'ancienne, gardée pour transition)
        if let endTomorrowDate = calendar.date(byAdding: .day, value: -1, to: contract.endDate),
           endTomorrowDate > now {
            
            let content = UNMutableNotificationContent()
            content.title = L(CommonTranslations.rentalEndsTomorrowTitle)
            content.body = "\(contract.renterName) \(L(CommonTranslations.rentalEndsTomorrowBody))"
            content.sound = .default
            
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: endTomorrowDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "rental_end_tomorrow_\(contract.id.uuidString)",
                content: content,
                trigger: trigger
            )
            center.add(request)
        }
    }
    
    private func cancelNotification(for contract: RentalContract) {
        let center = UNUserNotificationCenter.current()
        
        // Annuler toutes les notifications liées à ce contrat
        let identifiers = [
            "rental_start_tomorrow_\(contract.id.uuidString)",  // Location démarre demain
            "rental_start_soon_\(contract.id.uuidString)",      // Location dans 2h
            "rental_end_today_\(contract.id.uuidString)",       // Fin de location AUJOURD'HUI
            "rental_end_tomorrow_\(contract.id.uuidString)",    // Fin de location demain
            "rental_\(contract.id.uuidString)"                  // Ancien format (pour compatibilité)
        ]
        
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
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