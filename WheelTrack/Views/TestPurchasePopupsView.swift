import SwiftUI
import StoreKit

/// Vue de test spécialement conçue pour tester les pop-ups d'achat selon les différents types d'abonnements
public struct TestPurchasePopupsView: View {
    @StateObject private var freemiumService = FreemiumService.shared
    @StateObject private var storeKitService = StoreKitService.shared
    @State private var showPurchaseSuccess = false
    @State private var selectedPurchaseType: FreemiumService.PurchaseType = .monthly
    @State private var selectedProductID = "wheeltrack_premium_monthly"
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header de test
                    testHeader
                    
                    // Sélection du type d'achat à tester
                    purchaseTypeSelector
                    
                    // Boutons de test
                    testButtons
                    
                    // Informations sur l'état actuel
                    currentStateInfo
                    
                    // Test des prix réels
                    realPricesSection
                }
                .padding()
            }
            .navigationTitle("Test Pop-ups Achat")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                Task {
                    await storeKitService.loadProducts()
                }
            }
            .overlay {
                // Pop-up de test
                if showPurchaseSuccess {
                    PurchaseSuccessView(
                        purchaseType: selectedPurchaseType,
                        productID: selectedProductID
                    )
                    .onTapGesture {
                        showPurchaseSuccess = false
                    }
                }
            }
        }
    }
    
    private var testHeader: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
            Text("Test des Pop-ups d'Achat")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Testez les différentes pop-ups de confirmation selon le type d'abonnement")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var purchaseTypeSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Type d'Achat à Tester")
                .font(.headline)
            
            VStack(spacing: 8) {
                PurchaseTypeOption(
                    type: .monthly,
                    title: "Premium Mensuel",
                    subtitle: "Abonnement renouvelé chaque mois",
                    productID: "wheeltrack_premium_monthly",
                    isSelected: selectedPurchaseType == .monthly
                ) {
                    selectedPurchaseType = .monthly
                    selectedProductID = "wheeltrack_premium_monthly"
                }
                
                PurchaseTypeOption(
                    type: .yearly,
                    title: "Premium Annuel",
                    subtitle: "Abonnement renouvelé chaque année",
                    productID: "wheeltrack_premium_yearly",
                    isSelected: selectedPurchaseType == .yearly
                ) {
                    selectedPurchaseType = .yearly
                    selectedProductID = "wheeltrack_premium_yearly"
                }
                
                PurchaseTypeOption(
                    type: .lifetime,
                    title: "Premium à Vie",
                    subtitle: "Achat unique, pas de renouvellement",
                    productID: "wheeltrack_premium_lifetime",
                    isSelected: selectedPurchaseType == .lifetime
                ) {
                    selectedPurchaseType = .lifetime
                    selectedProductID = "wheeltrack_premium_lifetime"
                }
                
                PurchaseTypeOption(
                    type: .test,
                    title: "Mode Test",
                    subtitle: "Pour les tests de développement",
                    productID: "test_product",
                    isSelected: selectedPurchaseType == .test
                ) {
                    selectedPurchaseType = .test
                    selectedProductID = "test_product"
                }
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var testButtons: some View {
        VStack(spacing: 16) {
            Text("Actions de Test")
                .font(.headline)
            
            VStack(spacing: 12) {
                Button("🎉 Afficher Pop-up de Succès") {
                    showPurchaseSuccess = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("📱 Déclencher via FreemiumService") {
                    freemiumService.showPurchaseSuccessPopup(
                        purchaseType: selectedPurchaseType,
                        productID: selectedProductID
                    )
                }
                .buttonStyle(.bordered)
                
                Button("🔄 Simuler Achat Complet") {
                    simulateCompletePurchase()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.orange)
            }
        }
        .padding()
        .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var currentStateInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("État Actuel")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                PurchaseInfoRow(label: "Premium actif", value: freemiumService.isPremium ? "✅ Oui" : "❌ Non")
                PurchaseInfoRow(label: "Type d'achat", value: currentPurchaseTypeDescription)
                PurchaseInfoRow(label: "Pop-up de succès", value: freemiumService.showPurchaseSuccess ? "✅ Affiché" : "❌ Masqué")
                PurchaseInfoRow(label: "Dernier type acheté", value: lastPurchaseTypeDescription)
            }
        }
        .padding()
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var realPricesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prix Réels StoreKit")
                .font(.headline)
            
            if storeKitService.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Chargement des produits...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    if let monthlyProduct = storeKitService.product(for: .monthlySubscription) {
                        PurchaseInfoRow(label: "Mensuel", value: monthlyProduct.displayPrice)
                    } else {
                        PurchaseInfoRow(label: "Mensuel", value: "Non disponible")
                    }
                    
                    if let yearlyProduct = storeKitService.product(for: .yearlySubscription) {
                        PurchaseInfoRow(label: "Annuel", value: yearlyProduct.displayPrice)
                    } else {
                        PurchaseInfoRow(label: "Annuel", value: "Non disponible")
                    }
                    
                    if let lifetimeProduct = storeKitService.product(for: .lifetimePurchase) {
                        PurchaseInfoRow(label: "À vie", value: lifetimeProduct.displayPrice)
                    } else {
                        PurchaseInfoRow(label: "À vie", value: "Non disponible")
                    }
                }
            }
        }
        .padding()
        .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Computed Properties
    
    private var currentPurchaseTypeDescription: String {
        switch freemiumService.currentPurchaseType {
        case .monthly: return "Mensuel"
        case .yearly: return "Annuel"
        case .lifetime: return "À Vie"
        case .test: return "Test"
        }
    }
    
    private var lastPurchaseTypeDescription: String {
        switch freemiumService.lastPurchaseType {
        case .monthly: return "Mensuel"
        case .yearly: return "Annuel"
        case .lifetime: return "À Vie"
        case .test: return "Test"
        }
    }
    
    // MARK: - Methods
    
    private func simulateCompletePurchase() {
        // Simuler un achat complet avec activation Premium
        freemiumService.activatePremium(purchaseType: selectedPurchaseType)
        
        // Afficher la pop-up de succès
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            freemiumService.showPurchaseSuccessPopup(
                purchaseType: selectedPurchaseType,
                productID: selectedProductID
            )
        }
    }
}

// MARK: - Supporting Views

struct PurchaseTypeOption: View {
    let type: FreemiumService.PurchaseType
    let title: String
    let subtitle: String
    let productID: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("ID: \(productID)")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.7))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? .blue.opacity(0.1) : .clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? .blue : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct PurchaseInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

// MARK: - Preview

#Preview {
    TestPurchasePopupsView()
}
