import Foundation
import StoreKit
import Combine

/// Service de gestion des achats in-app avec StoreKit 2
@MainActor
public class StoreKitService: ObservableObject {
    public static let shared = StoreKitService()
    
    // MARK: - Published Properties
    @Published public var products: [Product] = []
    @Published public var purchasedProductIDs: Set<String> = []
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    
    // MARK: - Product IDs
    public enum ProductID: String, CaseIterable {
        case monthlySubscription = "wheeltrack_premium_monthly"
        case yearlySubscription = "wheeltrack_premium_yearly"
        case lifetimePurchase = "wheeltrack_premium_lifetime"
        
        var displayName: String {
            switch self {
            case .monthlySubscription:
                return "Premium Mensuel"
            case .yearlySubscription:
                return "Premium Annuel"
            case .lifetimePurchase:
                return "Premium à Vie"
            }
        }
    }
    
    // MARK: - Transaction Update Task
    private var updateListenerTask: Task<Void, Error>? = nil
    
    private init() {
        // Démarrer l'écoute des transactions
        updateListenerTask = listenForTransactions()
        
        // Charger les produits
        Task {
            await loadProducts()
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    /// Charge les produits depuis l'App Store
    public func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        print("🔄 Chargement des produits StoreKit...")
        
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            print("📱 IDs des produits à charger: \(productIDs)")
            
            let storeProducts = try await Product.products(for: productIDs)
            print("✅ Produits récupérés depuis StoreKit: \(storeProducts.count)")
            
            // Trier les produits : mensuel, annuel, lifetime
            let sortedProducts = storeProducts.sorted { product1, product2 in
                let order = [ProductID.monthlySubscription.rawValue, ProductID.yearlySubscription.rawValue, ProductID.lifetimePurchase.rawValue]
                let index1 = order.firstIndex(of: product1.id) ?? Int.max
                let index2 = order.firstIndex(of: product2.id) ?? Int.max
                return index1 < index2
            }
            
            products = sortedProducts
            
            // Log détaillé des produits chargés
            for product in sortedProducts {
                print("📦 Produit: \(product.id) - Nom: \(product.displayName) - Prix: \(product.displayPrice)")
            }
            
            print("✅ Produits chargés et triés: \(products.map { $0.id })")
            
        } catch {
            errorMessage = "Erreur lors du chargement des produits: \(error.localizedDescription)"
            print("❌ Erreur détaillée chargement produits: \(error)")
            
            // Log plus détaillé selon le type d'erreur
            if let storeError = error as? StoreError {
                print("❌ Erreur StoreKit: \(storeError.localizedDescription)")
            } else {
                print("❌ Erreur système: \(error)")
            }
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase Management
    
    /// Achète un produit
    public func purchase(_ product: Product) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        print("🛒 Début de l'achat pour: \(product.id) - Prix: \(product.displayPrice)")
        
        defer {
            isLoading = false
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                print("✅ Achat réussi, vérification en cours...")
                
                // Vérifier la transaction
                let transaction = try checkVerified(verification)
                print("✅ Transaction vérifiée: \(transaction.productID)")
                
                // Mettre à jour le statut
                await updateCustomerProductStatus()
                
                // Finaliser la transaction
                await transaction.finish()
                print("✅ Transaction finalisée")
                
                // Déclencher la pop-up de succès
                await triggerPurchaseSuccessPopup(for: product.id)
                
                print("✅ Achat complet réussi: \(product.id)")
                return true
                
            case .userCancelled:
                print("🚫 Achat annulé par l'utilisateur")
                errorMessage = "Achat annulé"
                return false
                
            case .pending:
                print("⏳ Achat en attente (approval familial)")
                errorMessage = "Achat en attente d'approbation"
                return false
                
            @unknown default:
                print("⚠️ Résultat d'achat inconnu: \(result)")
                errorMessage = "Résultat d'achat inattendu"
                return false
            }
        } catch {
            errorMessage = "Erreur lors de l'achat: \(error.localizedDescription)"
            print("❌ Erreur détaillée lors de l'achat: \(error)")
            
            // Log plus détaillé selon le type d'erreur
            if let storeError = error as? StoreError {
                print("❌ Erreur StoreKit: \(storeError.localizedDescription)")
            } else {
                print("❌ Erreur système: \(error)")
            }
            
            return false
        }
    }
    
    /// Restaure les achats précédents
    public func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
            print("✅ Achats restaurés")
        } catch {
            errorMessage = "Erreur lors de la restauration: \(error.localizedDescription)"
            print("❌ Erreur restauration: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Transaction Verification
    
    /// Vérifie la validité d'une transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Customer Status Update
    
    /// Met à jour le statut des produits achetés par le client
    public func updateCustomerProductStatus() async {
        var purchasedProducts: Set<String> = []
        var currentPurchaseType: FreemiumService.PurchaseType = .test
        
        // Vérifier les transactions non consommables (lifetime)
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                switch transaction.productType {
                case .nonConsumable:
                    // Achat unique (lifetime)
                    purchasedProducts.insert(transaction.productID)
                    if transaction.productID == ProductID.lifetimePurchase.rawValue {
                        currentPurchaseType = .lifetime
                    }
                    
                case .autoRenewable:
                    // Abonnement auto-renouvelable
                    purchasedProducts.insert(transaction.productID)
                    if transaction.productID == ProductID.yearlySubscription.rawValue {
                        currentPurchaseType = .yearly
                    } else if transaction.productID == ProductID.monthlySubscription.rawValue {
                        currentPurchaseType = .monthly
                    }
                    
                default:
                    break
                }
            } catch {
                print("❌ Erreur vérification transaction: \(error)")
            }
        }
        
        purchasedProductIDs = purchasedProducts
        
        // Mettre à jour le FreemiumService avec plus de précision
        await MainActor.run {
            let isPremium = !purchasedProducts.isEmpty
            FreemiumService.shared.isPremium = isPremium
            
            if isPremium {
                FreemiumService.shared.currentPurchaseType = currentPurchaseType
                print("📱 Statut premium mis à jour: \(isPremium) - Type: \(currentPurchaseType)")
            } else {
                FreemiumService.shared.currentPurchaseType = .test
                print("📱 Statut premium mis à jour: \(isPremium) - Type: Test")
            }
        }
        
        print("🛒 Produits achetés: \(purchasedProducts)")
    }
    
    // MARK: - Transaction Listener
    
    /// Écoute les nouvelles transactions
    private func listenForTransactions() -> Task<Void, Error> {
        return Task { @MainActor in
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    
                    // Mettre à jour le statut client
                    await updateCustomerProductStatus()
                    
                    // Finaliser la transaction
                    await transaction.finish()
                } catch {
                    print("❌ Erreur transaction listener: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Vérifie si un produit spécifique a été acheté
    public func isPurchased(_ productID: ProductID) -> Bool {
        return purchasedProductIDs.contains(productID.rawValue)
    }
    
    /// Obtient le produit pour un ID donné
    public func product(for productID: ProductID) -> Product? {
        return products.first { $0.id == productID.rawValue }
    }
    
    /// Formate le prix d'un produit
    public func formattedPrice(for product: Product) -> String {
        return product.displayPrice
    }
    
    /// Calcule l'économie pour l'abonnement annuel
    public func yearlyDiscount() -> String {
        guard let monthly = product(for: .monthlySubscription),
              let yearly = product(for: .yearlySubscription) else {
            return "18%"
        }
        
        let monthlyYearlyPrice = monthly.price * 12
        let savings = monthlyYearlyPrice - yearly.price
        let discount = (savings / monthlyYearlyPrice) * 100
        
        return String(format: "%.0f%%", Double(truncating: discount as NSNumber))
    }
    
    /// Prix mensuel équivalent pour l'abonnement annuel
    public func yearlyMonthlyEquivalent() -> String {
        guard let yearly = product(for: .yearlySubscription) else {
            return "4,08€/mois"
        }
        
        let monthlyPrice = yearly.price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = yearly.priceFormatStyle.locale
        
        return (formatter.string(from: monthlyPrice as NSDecimalNumber) ?? "4,08€") + "/mois"
    }
    
    /// Déclenche la pop-up de succès d'achat
    private func triggerPurchaseSuccessPopup(for productID: String) async {
        let purchaseType: FreemiumService.PurchaseType
        
        switch productID {
        case ProductID.monthlySubscription.rawValue:
            purchaseType = .monthly
        case ProductID.yearlySubscription.rawValue:
            purchaseType = .yearly
        case ProductID.lifetimePurchase.rawValue:
            purchaseType = .lifetime
        default:
            purchaseType = .test
        }
        
        await MainActor.run {
            FreemiumService.shared.showPurchaseSuccessPopup(purchaseType: purchaseType, productID: productID)
        }
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case failedVerification
    
    var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "Échec de la vérification de la transaction"
        }
    }
}