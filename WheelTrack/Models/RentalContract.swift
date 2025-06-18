import Foundation

struct RentalContract: Identifiable, Codable, Equatable {
    var id: UUID
    var vehicleId: UUID
    var renterName: String
    var startDate: Date
    var endDate: Date
    var pricePerDay: Double
    var totalPrice: Double
    var depositAmount: Double
    var conditionReport: String
    
    // Conformité à Equatable
    static func == (lhs: RentalContract, rhs: RentalContract) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Initializer principal
    init(vehicleId: UUID, renterName: String, startDate: Date, endDate: Date, pricePerDay: Double, conditionReport: String, depositAmount: Double = 0.0) {
        self.id = UUID()
        self.vehicleId = vehicleId
        self.renterName = renterName
        self.startDate = startDate
        self.endDate = endDate
        self.pricePerDay = pricePerDay
        self.conditionReport = conditionReport
        self.depositAmount = depositAmount
        
        // Calcul automatique du prix total
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        self.totalPrice = Double(days) * pricePerDay
    }
    
    // Initializer complet (si vous voulez spécifier tous les champs)
    init(id: UUID = UUID(), vehicleId: UUID, renterName: String, startDate: Date, endDate: Date, pricePerDay: Double, totalPrice: Double, conditionReport: String, depositAmount: Double = 0.0) {
        self.id = id
        self.vehicleId = vehicleId
        self.renterName = renterName
        self.startDate = startDate
        self.endDate = endDate
        self.pricePerDay = pricePerDay
        self.totalPrice = totalPrice
        self.conditionReport = conditionReport
        self.depositAmount = depositAmount
    }
    
    // Méthode pour calculer le prix total
    private func calculateTotalPrice() -> Double {
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return Double(days) * pricePerDay
    }
    
    // Propriété calculée pour obtenir le nombre de jours
    var numberOfDays: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    // Méthode pour vérifier si le contrat est actif
    func isActive() -> Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }
    
    // Méthode pour vérifier si le contrat est expiré
    func isExpired() -> Bool {
        return Date() > endDate
    }
    
    // Méthode pour obtenir le statut du contrat
    func getStatus() -> String {
        let now = Date()
        if now < startDate {
            return "À venir"
        } else if now >= startDate && now <= endDate {
            return "Actif"
        } else {
            return "Expiré"
        }
    }
} 