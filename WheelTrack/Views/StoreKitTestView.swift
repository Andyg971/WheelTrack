import SwiftUI
import StoreKit

/// Vue de test pour les fonctionnalités StoreKit
struct StoreKitTestView: View {
    @StateObject private var storeKitService = StoreKitService.shared
    @StateObject private var freemiumService = FreemiumService.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingReceiptValidation = false
    @State private var validationResult: ReceiptValidationResult?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Status Section
                StatusSection()
                
                // Products Section
                ProductsSection()
                
                // Actions Section
                ActionsSection()
                
                // Validation Section
                ValidationSection()
                
                Spacer()
            }
            .padding()
            .navigationTitle("StoreKit Test")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("StoreKit", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingReceiptValidation) {
            ReceiptValidationDetailView(result: $validationResult)
        }
        .onAppear {
            Task {
                await storeKitService.loadProducts()
            }
        }
    }
    
    @ViewBuilder
    private func StatusSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(.headline)
            
            HStack {
                Circle()
                    .fill(freemiumService.isPremium ? .green : .red)
                    .frame(width: 10, height: 10)
                
                Text(freemiumService.isPremium ? "Premium Actif" : "Version Gratuite")
                    .font(.subheadline)
                
                Spacer()
                
                Text("Environnement: \(AppStoreConfigService.shared.getCurrentEnvironment().rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !storeKitService.purchasedProductIDs.isEmpty {
                VStack(alignment: .leading) {
                    Text("Produits achetés:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(Array(storeKitService.purchasedProductIDs), id: \.self) { productID in
                        Text("• \(productID)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private func ProductsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Produits Disponibles")
                .font(.headline)
            
            if storeKitService.products.isEmpty {
                if storeKitService.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Chargement...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Aucun produit trouvé")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let error = storeKitService.errorMessage {
                            Text("Erreur: \(error)")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            } else {
                ForEach(storeKitService.products, id: \.id) { product in
                    ProductRow(product: product)
                }
            }
        }
    }
    
    @ViewBuilder
    private func ProductRow(product: Product) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text("ID: \(product.id)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if storeKitService.purchasedProductIDs.contains(product.id) {
                            Text("✅ Acheté")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(product.displayPrice)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Button("Acheter") {
                        Task {
                            let success = await storeKitService.purchase(product)
                            await MainActor.run {
                                alertMessage = success ? "Achat réussi!" : "Achat échoué"
                                showingAlert = true
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(storeKitService.isLoading || storeKitService.purchasedProductIDs.contains(product.id))
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    private func ActionsSection() -> some View {
        VStack(spacing: 12) {
            Text("Actions de Test")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                Button("Recharger Produits") {
                    Task {
                        await storeKitService.loadProducts()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(storeKitService.isLoading)
                
                Button("Restaurer Achats") {
                    Task {
                        await storeKitService.restorePurchases()
                        await MainActor.run {
                            alertMessage = "Restauration terminée"
                            showingAlert = true
                        }
                    }
                }
                .buttonStyle(.bordered)
                .disabled(storeKitService.isLoading)
                
                Button("Toggle Premium") {
                    if freemiumService.isPremium {
                        freemiumService.deactivatePremium()
                    } else {
                        freemiumService.activatePremium()
                    }
                }
                .buttonStyle(.bordered)
                
                Button("Debug Config") {
                    let debugInfo = AppStoreConfigService.shared.getDebugInfo()
                    alertMessage = debugInfo.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
                    showingAlert = true
                }
                .buttonStyle(.bordered)
            }
        }
    }
    
    @ViewBuilder
    private func ValidationSection() -> some View {
        VStack(spacing: 12) {
            Text("Validation des Reçus")
                .font(.headline)
            
            Button("Valider Reçu Serveur") {
                Task {
                    do {
                        let result = try await ReceiptValidationService.shared.validateReceipt()
                        await MainActor.run {
                            validationResult = result
                            showingReceiptValidation = true
                        }
                    } catch {
                        await MainActor.run {
                            alertMessage = "Erreur validation: \(error.localizedDescription)"
                            showingAlert = true
                        }
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Valider Configuration") {
                let errors = AppStoreConfigService.shared.validateConfiguration()
                alertMessage = errors.isEmpty ? "Configuration OK ✅" : "Erreurs:\n\(errors.joined(separator: "\n"))"
                showingAlert = true
            }
            .buttonStyle(.bordered)
        }
    }
}

// MARK: - Receipt Validation Detail View

struct ReceiptValidationDetailView: View {
    @Binding var result: ReceiptValidationResult?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                if let result = result {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Validation Réussie")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Circle()
                                .fill(result.isValid ? .green : .red)
                                .frame(width: 12, height: 12)
                        }
                        
                        Divider()
                        
                        StoreKitInfoRow(label: "Premium", value: result.isPremium ? "Actif" : "Inactif")
                        StoreKitInfoRow(label: "Version Originale", value: result.originalAppVersion ?? "N/A")
                        
                        if !result.activeSubscriptions.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Abonnements Actifs:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                ForEach(result.activeSubscriptions, id: \.self) { subscription in
                                    Text("• \(subscription)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        if !result.lifetimePurchases.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Achats Permanents:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                ForEach(result.lifetimePurchases, id: \.self) { purchase in
                                    Text("• \(purchase)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    Spacer()
                } else {
                    Text("Aucun résultat de validation")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Validation Reçu")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct StoreKitInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    StoreKitTestView()
}
