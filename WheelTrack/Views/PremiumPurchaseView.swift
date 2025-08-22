import SwiftUI
import StoreKit

/// Vue d'achat principale pour WheelTrack Premium
struct PremiumPurchaseView: View {
    @StateObject private var storeKitService = StoreKitService.shared
    @StateObject private var freemiumService = FreemiumService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Premium
                    premiumHeader
                    
                    // Produits disponibles
                    if storeKitService.isLoading {
                        loadingView
                    } else if storeKitService.products.isEmpty {
                        noProductsView
                    } else {
                        productsSection
                    }
                    
                    // Bouton restaurer achats
                    restorePurchasesButton
                    
                    // Footer légal
                    legalFooter
                }
                .padding()
            }
            .navigationTitle("WheelTrack Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
            .onAppear {
                Task {
                    await storeKitService.loadProducts()
                }
            }
            .alert("Erreur", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var premiumHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Débloquez WheelTrack Premium")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Accédez à toutes les fonctionnalités avancées")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var productsSection: some View {
        VStack(spacing: 16) {
            ForEach(storeKitService.products, id: \.id) { product in
                ProductCard(
                    product: product,
                    isPurchased: storeKitService.purchasedProductIDs.contains(product.id),
                    onPurchase: {
                        Task {
                            await purchaseProduct(product)
                        }
                    }
                )
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Chargement des produits...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(height: 100)
    }
    
    private var noProductsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Aucun produit disponible")
                .font(.headline)
            
            if let error = storeKitService.errorMessage {
                Text("Erreur: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 150)
    }
    
    private var restorePurchasesButton: some View {
        Button {
            Task {
                await storeKitService.restorePurchases()
            }
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Restaurer les achats")
            }
            .font(.subheadline)
            .foregroundColor(.blue)
        }
        .disabled(storeKitService.isLoading)
    }
    
    private var legalFooter: some View {
        VStack(spacing: 8) {
            Text("• Abonnement renouvelé automatiquement")
            Text("• Annulation possible à tout moment")
            Text("• Essai gratuit de 7 jours")
        }
        .font(.caption2)
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
    }
    
    private func purchaseProduct(_ product: Product) async {
        isProcessing = true
        
        let success = await storeKitService.purchase(product)
        
        await MainActor.run {
            isProcessing = false
            
            if success {
                dismiss()
            } else {
                errorMessage = "L'achat a échoué. Veuillez réessayer."
                showError = true
            }
        }
    }
}

struct ProductCard: View {
    let product: Product
    let isPurchased: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Badge populaire pour l'abonnement annuel
            if product.id.contains("yearly") {
                Text("⭐ POPULAIRE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.blue)
                    .clipShape(Capsule())
            }
            
            VStack(spacing: 8) {
                Text(product.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(product.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(product.displayPrice)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                // Prix mensuel équivalent pour l'abonnement annuel
                if product.id.contains("yearly") {
                    Text("4,08€/mois")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            if isPurchased {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Acheté")
                }
                .font(.subheadline)
                .foregroundColor(.green)
            } else {
                Button("Acheter") {
                    onPurchase()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isPurchased)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    product.id.contains("yearly") ? .blue : Color(.systemGray4),
                    lineWidth: product.id.contains("yearly") ? 2 : 1
                )
        )
    }
}

#Preview {
    PremiumPurchaseView()
}
