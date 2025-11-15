import Foundation
import StoreKit

/// Service de validation des reçus côté serveur
public class ReceiptValidationService {
    public static let shared = ReceiptValidationService()
    
    // MARK: - Configuration
    private let sandboxURL = "https://sandbox.itunes.apple.com/verifyReceipt"
    private let productionURL = "https://buy.itunes.apple.com/verifyReceipt"
    
    // TODO: Remplacer par votre clé secrète partagée App Store Connect
    // Pour l'obtenir : App Store Connect → Users and Access → Keys → Create New Key
    // Cochez "In-App Purchase" et "App Analytics"
    private let sharedSecret = "VOTRE_SHARED_SECRET_ICI"
    
    private init() {}
    
    // MARK: - Receipt Validation
    
    /// Valide un reçu auprès des serveurs Apple
    public func validateReceipt() async throws -> ReceiptValidationResult {
        // Pour iOS 18+, utiliser la nouvelle API StoreKit 2
        if #available(iOS 18.0, *) {
            print("🔄 iOS 18+ détecté - Utilisation de StoreKit 2")
            return try await validateModernReceipt()
        }
        
        // Pour iOS 17 et versions antérieures, utiliser l'ancienne méthode
        guard let receiptData = getReceiptData() else {
            throw ValidationError.noReceiptFound
        }
        
        // Essayer d'abord en production, puis en sandbox
        do {
            return try await validateWithApple(receiptData: receiptData, isProduction: true)
        } catch {
            // Si échec en production, essayer en sandbox
            return try await validateWithApple(receiptData: receiptData, isProduction: false)
        }
    }
    
    /// Obtient les données du reçu local
    private func getReceiptData() -> Data? {
        // Utilisation de la nouvelle API StoreKit 2 pour iOS 18+
        if #available(iOS 18.0, *) {
            let modernData = getReceiptDataModern()
            if modernData != nil {
                return modernData
            }
            // Si la méthode moderne échoue, on utilise la méthode alternative
            return getReceiptDataAlternative()
        }
        
        // Fallback pour iOS 17 et versions antérieures
        // Note: appStoreReceiptURL est déprécié en iOS 18+, mais nécessaire pour la compatibilité
        return getReceiptDataLegacy()
    }
    
    /// Méthode legacy utilisant l'API dépréciée pour iOS 17 et versions antérieures
    private func getReceiptDataLegacy() -> Data? {
        // Cette méthode utilise Bundle.main.appStoreReceiptURL qui est déprécié en iOS 18+
        // mais reste nécessaire pour la compatibilité avec iOS 17 et versions antérieures
        
        // Version simplifiée qui évite les variables inutilisées
        if #available(iOS 18.0, *) {
            // Pour iOS 18+, cette méthode ne devrait pas être appelée
            print("⚠️ Utilisation de l'API legacy sur iOS 18+ - Migration recommandée")
        }
        
        // Accès direct à l'API legacy avec gestion d'erreur
        return getReceiptFromBundle()
    }
    
    /// Accède directement au receipt bundle (isolé pour gérer la dépréciation)
    /// - Note: Cette fonction isole intentionnellement l'utilisation de l'API dépréciée
    private func getReceiptFromBundle() -> Data? {
        // Cette fonction utilise intentionnellement Bundle.main.appStoreReceiptURL
        // qui est déprécié en iOS 18+ mais nécessaire pour la compatibilité iOS 17-
        
        // Suppression de l'avertissement pour cette utilisation spécifique et documentée
        if #available(iOS 18.0, *) {
            // Pour iOS 18+, on évite l'API dépréciée
            print("⚠️ Utilisation de l'API legacy évitée sur iOS 18+")
            return nil
        } else {
            // Pour iOS 17 et versions antérieures, on utilise l'API legacy
            guard let receiptURL = Bundle.main.appStoreReceiptURL,
                  let receiptData = try? Data(contentsOf: receiptURL) else {
                print("❌ Aucun reçu trouvé localement (méthode legacy)")
                return nil
            }
            
            print("✅ Reçu trouvé avec l'API legacy (iOS 17- compatible)")
            return receiptData
        }
    }
    
    /// Méthode alternative pour iOS 18+ qui n'utilise pas l'API dépréciée
    @available(iOS 18.0, *)
    private func getReceiptDataAlternative() -> Data? {
        // Pour iOS 18+, nous recommandons d'utiliser StoreKit 2
        // Cette méthode évite l'utilisation de appStoreReceiptURL déprécié
        print("ℹ️ iOS 18+ - Utilisation de la méthode alternative (StoreKit 2 recommandé)")
        
        // Pour l'instant, retourne nil pour forcer l'utilisation du fallback
        // TODO: Implémenter la logique avec AppTransaction.shared et Transaction.all
        return nil
    }
    
    /// Nouvelle méthode pour iOS 18+ utilisant AppTransaction.shared et Transaction.all
    @available(iOS 18.0, *)
    private func getReceiptDataModern() -> Data? {
        print("ℹ️ iOS 18+ - Utilisation de StoreKit 2 avec AppTransaction.shared")
        
        // Note: StoreKit 2 utilise une approche différente avec AppTransaction et Transaction
        // Cette méthode retourne nil car la validation doit maintenant se faire via 
        // validateModernReceipt() qui utilise directement AppTransaction.shared
        // et Transaction.all au lieu des anciens reçus encodés
        return nil
    }
    
    /// Validation moderne utilisant StoreKit 2 pour iOS 18+
    @available(iOS 18.0, *)
    public func validateModernReceipt() async throws -> ReceiptValidationResult {
        print("🔄 iOS 18+ - Validation avec StoreKit 2 (AppTransaction.shared)")
        
        do {
            // Récupérer les informations de l'app transaction
            let appTransaction = try await AppTransaction.shared
            
            // Vérifier si l'app transaction est valide
            guard case .verified(let transaction) = appTransaction else {
                print("❌ AppTransaction non vérifiée")
                throw ValidationError.validationFailed
            }
            
            print("✅ AppTransaction vérifiée - Bundle ID: \(transaction.bundleID)")
            
            // Récupérer toutes les transactions
            var activeSubscriptions: [String] = []
            var lifetimePurchases: [String] = []
            
            // Itérer sur toutes les transactions
            for await result in Transaction.all {
                guard case .verified(let transaction) = result else {
                    continue
                }
                
                // Vérifier si c'est un achat à vie
                if transaction.productID == "com.andygrava.wheeltrack.premium.lifetime" {
                    lifetimePurchases.append(transaction.productID)
                    print("✅ Achat à vie trouvé: \(transaction.productID)")
                }
                
                // Vérifier si c'est un abonnement actif
                if let expirationDate = transaction.expirationDate,
                   expirationDate > Date() {
                    activeSubscriptions.append(transaction.productID)
                    print("✅ Abonnement actif trouvé: \(transaction.productID), expire: \(expirationDate)")
                }
            }
            
            let isPremium = !activeSubscriptions.isEmpty || !lifetimePurchases.isEmpty
            
            print("📊 Résultat validation moderne - Premium: \(isPremium), Abonnements: \(activeSubscriptions.count), Achats à vie: \(lifetimePurchases.count)")
            
            return ReceiptValidationResult(
                isValid: true,
                isPremium: isPremium,
                activeSubscriptions: activeSubscriptions,
                lifetimePurchases: lifetimePurchases,
                originalAppVersion: transaction.appVersion
            )
            
        } catch {
            print("❌ Erreur lors de la validation moderne: \(error)")
            throw ValidationError.validationFailed
        }
    }
    
    /// Valide le reçu avec les serveurs Apple
    private func validateWithApple(receiptData: Data, isProduction: Bool) async throws -> ReceiptValidationResult {
        let base64Receipt = receiptData.base64EncodedString()
        let url = URL(string: isProduction ? productionURL : sandboxURL)!
        
        let requestBody: [String: Any] = [
            "receipt-data": base64Receipt,
            "password": sharedSecret,
            "exclude-old-transactions": true
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ValidationError.networkError
        }
        
        let validationResponse = try JSONDecoder().decode(AppleReceiptResponse.self, from: data)
        
        switch validationResponse.status {
        case 0:
            // Succès
            return parseReceiptData(validationResponse)
        case 21007:
            // Reçu sandbox en production - retry en sandbox
            if isProduction {
                throw ValidationError.sandboxReceiptInProduction
            } else {
                throw ValidationError.validationFailed
            }
        default:
            throw ValidationError.validationFailed
        }
    }
    
    /// Parse les données du reçu validé
    private func parseReceiptData(_ response: AppleReceiptResponse) -> ReceiptValidationResult {
        var activeSubscriptions: [String] = []
        var lifetimePurchases: [String] = []
        
        // Analyser les achats in-app
        for purchase in response.receipt.inApp {
            if purchase.productId == "com.andygrava.wheeltrack.premium.lifetime" {
                lifetimePurchases.append(purchase.productId)
            } else if let expiresDate = purchase.expiresDateMs,
                      Date().timeIntervalSince1970 * 1000 < expiresDate {
                // Abonnement actif
                activeSubscriptions.append(purchase.productId)
            }
        }
        
        // Vérifier aussi les dernières informations d'abonnement
        if let latestReceiptInfo = response.latestReceiptInfo {
            for subscription in latestReceiptInfo {
                if let expiresDate = subscription.expiresDateMs,
                   Date().timeIntervalSince1970 * 1000 < expiresDate {
                    activeSubscriptions.append(subscription.productId)
                }
            }
        }
        
        let isPremium = !activeSubscriptions.isEmpty || !lifetimePurchases.isEmpty
        
        return ReceiptValidationResult(
            isValid: true,
            isPremium: isPremium,
            activeSubscriptions: activeSubscriptions,
            lifetimePurchases: lifetimePurchases,
            originalAppVersion: response.receipt.originalApplicationVersion
        )
    }
}

// MARK: - Data Models

public struct ReceiptValidationResult {
    public let isValid: Bool
    public let isPremium: Bool
    public let activeSubscriptions: [String]
    public let lifetimePurchases: [String]
    public let originalAppVersion: String?
}

public struct AppleReceiptResponse: Codable {
    public let status: Int
    public let receipt: ReceiptInfo
    public let latestReceiptInfo: [InAppPurchaseInfo]?
    
    enum CodingKeys: String, CodingKey {
        case status, receipt
        case latestReceiptInfo = "latest_receipt_info"
    }
}

public struct ReceiptInfo: Codable {
    public let bundleId: String
    public let applicationVersion: String
    public let originalApplicationVersion: String
    public let inApp: [InAppPurchaseInfo]
    
    enum CodingKeys: String, CodingKey {
        case bundleId = "bundle_id"
        case applicationVersion = "application_version"
        case originalApplicationVersion = "original_application_version"
        case inApp = "in_app"
    }
}

public struct InAppPurchaseInfo: Codable {
    public let productId: String
    public let transactionId: String
    public let originalTransactionId: String
    public let purchaseDateMs: String
    public let expiresDateMs: Double?
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case transactionId = "transaction_id"
        case originalTransactionId = "original_transaction_id"
        case purchaseDateMs = "purchase_date_ms"
        case expiresDateMs = "expires_date_ms"
    }
}

public enum ValidationError: Error, LocalizedError {
    case noReceiptFound
    case networkError
    case validationFailed
    case sandboxReceiptInProduction
    
    public var errorDescription: String? {
        switch self {
        case .noReceiptFound:
            return "Aucun reçu trouvé"
        case .networkError:
            return "Erreur réseau lors de la validation"
        case .validationFailed:
            return "Échec de la validation du reçu"
        case .sandboxReceiptInProduction:
            return "Reçu sandbox détecté en production"
        }
    }
}
