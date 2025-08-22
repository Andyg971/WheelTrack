import Foundation
import Combine

/// Service de gestion du système freemium de WheelTrack
@MainActor
public class FreemiumService: ObservableObject {
    public static let shared = FreemiumService()
    
    // MARK: - Published Properties
    @Published public var isPremium: Bool = false
    @Published public var showUpgradeAlert: Bool = false
    @Published public var upgradeMessage: String = ""
    @Published public var blockedFeature: PremiumFeature?
    
    // MARK: - Purchase Success
    @Published public var showPurchaseSuccess: Bool = false
    @Published public var lastPurchaseType: PurchaseType = .test
    @Published public var lastProductID: String = ""
    
    // MARK: - Purchase Type
    public enum PurchaseType {
        case monthly
        case yearly
        case lifetime
        case test
    }
    
    @Published public var currentPurchaseType: PurchaseType = .test
    
    // MARK: - Configuration Freemium
    public enum PremiumFeature {
        case unlimitedVehicles
        case advancedAnalytics
        case rentalModule
        case pdfExport
        case garageModule
        case maintenanceReminders
        case cloudSync
        
        var title: String {
            switch self {
            case .unlimitedVehicles:
                return "Véhicules illimités"
            case .advancedAnalytics:
                return "Analytics avancés"
            case .rentalModule:
                return "Module Location"
            case .pdfExport:
                return "Export PDF"
            case .garageModule:
                return "Garages favoris"
            case .maintenanceReminders:
                return "Rappels maintenance"
            case .cloudSync:
                return "Synchronisation iCloud"
            }
        }
        
        var description: String {
            switch self {
            case .unlimitedVehicles:
                return "Ajoutez autant de véhicules que vous voulez"
            case .advancedAnalytics:
                return "Graphiques détaillés et statistiques complètes"
            case .rentalModule:
                return "Gérez la location de vos véhicules"
            case .pdfExport:
                return "Exportez vos données en PDF"
            case .garageModule:
                return "Sauvegardez vos garages favoris"
            case .maintenanceReminders:
                return "Rappels illimités pour l'entretien"
            case .cloudSync:
                return "Synchronisez vos données sur tous vos appareils"
            }
        }
        
        var icon: String {
            switch self {
            case .unlimitedVehicles:
                return "car.2.fill"
            case .advancedAnalytics:
                return "chart.bar.xaxis"
            case .rentalModule:
                return "key.radiowaves.forward.fill"
            case .pdfExport:
                return "doc.text.fill"
            case .garageModule:
                return "building.2.fill"
            case .maintenanceReminders:
                return "bell.fill"
            case .cloudSync:
                return "icloud.fill"
            }
        }
    }
    
    // MARK: - Limites Version Gratuite
    public let maxVehiclesFree = 2
    public let maxReminders = 3
    public let maxRentalsFree = 2  // 2 contrats de location gratuits
    
    private init() {
        loadPremiumStatus()
    }
    
    // MARK: - Méthodes publiques
    
    /// Vérifie si l'utilisateur peut ajouter un véhicule
    public func canAddVehicle(currentCount: Int) -> Bool {
        if isPremium {
            return true
        }
        return currentCount < maxVehiclesFree
    }
    
    /// Vérifie si l'utilisateur peut ajouter un contrat de location
    public func canAddRental(currentCount: Int) -> Bool {
        if isPremium {
            return true
        }
        return currentCount < maxRentalsFree
    }
    
        /// Vérifie l'accès à une fonctionnalité premium
    public func hasAccess(to feature: PremiumFeature) -> Bool {
        return isPremium
    }
    
    /// Vérifie l'accès de base au module location (pour voir les contrats existants)
    public func hasBasicAccessToRentals() -> Bool {
        return true // Tout le monde peut voir ses contrats existants
    }
    
    /// Affiche une alerte d'upgrade pour une fonctionnalité
    public func requestUpgrade(for feature: PremiumFeature) {
        // ✅ S'assurer que blockedFeature est défini AVANT showUpgradeAlert
        blockedFeature = feature
        upgradeMessage = "Cette fonctionnalité nécessite WheelTrack Premium"
        
        // ✅ Détection automatique des simulateurs pour optimiser le timing
        #if targetEnvironment(simulator)
        // Délai plus long pour les simulateurs (évite les bugs de timing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showUpgradeAlert = true
            print("🔒 FreemiumService - Alerte Premium affichée pour: \(feature) (Simulateur)")
        }
        #else
        // Délai minimal pour les appareils réels
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.showUpgradeAlert = true
            print("🔒 FreemiumService - Alerte Premium affichée pour: \(feature) (Appareil réel)")
        }
        #endif
    }
    
    // ✅ Ajouter une méthode pour fermer proprement l'alerte
    public func dismissUpgradeAlert() {
        showUpgradeAlert = false
        blockedFeature = nil
        upgradeMessage = ""
    }
    
    /// Active la version premium (pour les tests)
    public func activatePremium() {
        isPremium = true
        currentPurchaseType = .test
        savePremiumStatus()
    }
    
    /// Active la version premium avec un type d'achat spécifique
    public func activatePremium(purchaseType: PurchaseType) {
        isPremium = true
        currentPurchaseType = purchaseType
        savePremiumStatus()
    }
    
    /// Déclenche l'affichage de la pop-up de succès d'achat
    public func showPurchaseSuccessPopup(purchaseType: PurchaseType, productID: String) {
        lastPurchaseType = purchaseType
        lastProductID = productID
        showPurchaseSuccess = true
    }
    
    /// Désactive la version premium
    public func deactivatePremium() {
        isPremium = false
        currentPurchaseType = .test
        savePremiumStatus()
    }
    
    /// Obtient le message de limitation pour une fonctionnalité
    public func getLimitationMessage(for feature: PremiumFeature) -> String {
        switch feature {
        case .unlimitedVehicles:
            return "Version gratuite limitée à \(maxVehiclesFree) véhicules"
        case .advancedAnalytics:
            return "Analytics détaillés disponibles en Premium"
        case .rentalModule:
            return "Version gratuite limitée à \(maxRentalsFree) contrats de location"
        case .pdfExport:
            return "Export PDF disponible en Premium"
        case .garageModule:
            return "Garages favoris disponibles en Premium"
        case .maintenanceReminders:
            return "Rappels illimités disponibles en Premium"
        case .cloudSync:
            return "Synchronisation disponible en Premium"
        }
    }
    
    // MARK: - Persistance
    private func loadPremiumStatus() {
        isPremium = UserDefaults.standard.bool(forKey: "is_premium_user")
        if let purchaseTypeString = UserDefaults.standard.string(forKey: "purchase_type"),
           let purchaseType = purchaseTypeFromString(purchaseTypeString) {
            currentPurchaseType = purchaseType
        }
    }
    
    private func savePremiumStatus() {
        UserDefaults.standard.set(isPremium, forKey: "is_premium_user")
        UserDefaults.standard.set(stringFromPurchaseType(currentPurchaseType), forKey: "purchase_type")
    }
    
    private func purchaseTypeFromString(_ string: String) -> PurchaseType? {
        switch string {
        case "monthly": return .monthly
        case "yearly": return .yearly
        case "lifetime": return .lifetime
        case "test": return .test
        default: return nil
        }
    }
    
    private func stringFromPurchaseType(_ type: PurchaseType) -> String {
        switch type {
        case .monthly: return "monthly"
        case .yearly: return "yearly"
        case .lifetime: return "lifetime"
        case .test: return "test"
        }
    }
} 