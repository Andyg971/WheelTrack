import SwiftUI
import StoreKit

/// Vue de débogage complète pour tester StoreKit
struct StoreKitDebugView: View {
    @StateObject private var storeKitService = StoreKitService.shared
    @State private var debugLog: [String] = []
    @State private var isTestingPurchase = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // En-tête de statut
                    statusHeader
                    
                    // Bouton de rechargement des produits
                    reloadButton
                    
                    // Liste des produits détectés
                    productsSection
                    
                    // Log de débogage
                    debugLogSection
                    
                    // Bouton de test direct
                    directTestButton
                }
                .padding()
            }
            .navigationTitle("🔧 Debug StoreKit")
            .onAppear {
                addLog("✅ Vue de debug chargée")
                Task {
                    addLog("🔄 Tentative de chargement des produits...")
                    await storeKitService.loadProducts()
                    addLog("✅ Chargement terminé")
                    addLog("📦 Nombre de produits: \(storeKitService.products.count)")
                }
            }
        }
    }
    
    private var statusHeader: some View {
        VStack(spacing: 12) {
            Text("Statut StoreKit")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack {
                    Image(systemName: storeKitService.isLoading ? "hourglass" : "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(storeKitService.isLoading ? .orange : .green)
                    Text(storeKitService.isLoading ? "Chargement..." : "Prêt")
                        .font(.caption)
                }
                
                VStack {
                    Text("\(storeKitService.products.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Produits")
                        .font(.caption)
                }
                
                VStack {
                    Text("\(storeKitService.purchasedProductIDs.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    Text("Achats")
                        .font(.caption)
                }
            }
            
            if let error = storeKitService.errorMessage {
                Text("❌ Erreur: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
    
    private var reloadButton: some View {
        Button {
            addLog("🔄 Rechargement manuel des produits...")
            Task {
                await storeKitService.loadProducts()
                addLog("✅ Rechargement terminé: \(storeKitService.products.count) produits")
            }
        } label: {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Recharger les produits")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue)
            .cornerRadius(12)
        }
        .disabled(storeKitService.isLoading)
    }
    
    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Produits disponibles (\(storeKitService.products.count))")
                .font(.headline)
            
            if storeKitService.products.isEmpty {
                Text("⚠️ Aucun produit chargé")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            } else {
                ForEach(storeKitService.products, id: \.id) { product in
                    DebugProductCard(product: product) {
                        addLog("🛒 Tentative d'achat: \(product.id)")
                        isTestingPurchase = true
                        Task {
                            addLog("🔄 Début du processus d'achat...")
                            let success = await storeKitService.purchase(product)
                            addLog(success ? "✅ Achat réussi!" : "❌ Achat échoué")
                            isTestingPurchase = false
                        }
                    }
                }
            }
        }
    }
    
    private var debugLogSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Log de débogage")
                    .font(.headline)
                
                Spacer()
                
                Button("Effacer") {
                    debugLog.removeAll()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(debugLog.enumerated()), id: \.offset) { index, log in
                        Text("[\(index + 1)] \(log)")
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(height: 200)
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    private var directTestButton: some View {
        VStack(spacing: 12) {
            Text("Test StoreKit Direct")
                .font(.headline)
            
            Button {
                addLog("🧪 Test direct de StoreKit API...")
                Task {
                    await testDirectStoreKit()
                }
            } label: {
                HStack {
                    Image(systemName: "hammer.fill")
                    Text("Tester l'API StoreKit")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.purple)
                .cornerRadius(12)
            }
        }
        .padding(.top)
    }
    
    private func addLog(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        debugLog.append("[\(timestamp)] \(message)")
        print("🔧 DEBUG: \(message)")
    }
    
    private func testDirectStoreKit() async {
        addLog("📱 Test de Product.products()...")
        
        do {
            let productIDs = [
                "com.andygrava.wheeltrack.premium.monthly",
                "com.andygrava.wheeltrack.premium.yearly",
                "com.andygrava.wheeltrack.premium.lifetime"
            ]
            
            addLog("🔍 Recherche des produits: \(productIDs.joined(separator: ", "))")
            
            let products = try await Product.products(for: productIDs)
            
            addLog("✅ API StoreKit répond: \(products.count) produits trouvés")
            
            for product in products {
                addLog("  • \(product.id): \(product.displayName) - \(product.displayPrice)")
            }
            
            if products.isEmpty {
                addLog("⚠️ PROBLÈME: Aucun produit retourné par l'API")
                addLog("💡 Vérifiez que Configuration.storekit est bien configuré dans le scheme")
            }
            
        } catch {
            addLog("❌ Erreur API StoreKit: \(error.localizedDescription)")
        }
    }
}

struct DebugProductCard: View {
    let product: Product
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                        .font(.headline)
                    Text(product.id)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Text(product.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button {
                onPurchase()
            } label: {
                HStack {
                    Image(systemName: "cart.fill")
                    Text("Tester l'achat")
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(.green)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    StoreKitDebugView()
}

