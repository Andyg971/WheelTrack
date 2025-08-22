import SwiftUI
import StoreKit

/// Alerte moderne pour proposer l'upgrade vers Premium
struct PremiumUpgradeAlert: View {
    let feature: FreemiumService.PremiumFeature
    @ObservedObject private var freemiumService = FreemiumService.shared
    @ObservedObject private var storeKitService = StoreKitService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showFullUpgradeView = false
    
    private let gradientColors = [
        Color(red: 0.2, green: 0.7, blue: 1.0),
        Color(red: 0.1, green: 0.5, blue: 0.9)
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header avec icône
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: feature.icon)
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                Text("💎 Premium Requis")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(feature.title)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Description de la fonctionnalité
            VStack(spacing: 16) {
                Text(feature.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                // Avantages Premium
                VStack(alignment: .leading, spacing: 8) {
                    PremiumBenefitRow(
                        icon: "infinity.circle.fill",
                        text: "Véhicules illimités",
                        color: .blue
                    )
                    
                    PremiumBenefitRow(
                        icon: "chart.bar.xaxis",
                        text: "Analytics professionnels",
                        color: .green
                    )
                    
                    PremiumBenefitRow(
                        icon: "key.radiowaves.forward.fill",
                        text: "Module Location complet",
                        color: .orange
                    )
                    
                    PremiumBenefitRow(
                        icon: "icloud.fill",
                        text: "Synchronisation iCloud",
                        color: .purple
                    )
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.regularMaterial)
                )
            }
            
            // Options de pricing avec version à vie
            VStack(spacing: 12) {
                // Vérifier si les produits sont chargés
                if storeKitService.products.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Chargement des options...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Button("Recharger les produits") {
                            Task {
                                await storeKitService.loadProducts()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                } else {
                    // Premium Mensuel
                    if let monthlyProduct = storeKitService.product(for: .monthlySubscription) {
                        PricingOptionView(
                            title: "Premium Mensuel",
                            subtitle: "Facturé mensuellement",
                            price: monthlyProduct.displayPrice,
                            isPopular: false,
                            isLoading: storeKitService.isLoading,
                            action: {
                                Task {
                                    let success = await storeKitService.purchase(monthlyProduct)
                                    if success {
                                        dismiss()
                                    }
                                }
                            }
                        )
                    }
                    
                    // Premium Annuel (Populaire)
                    if let yearlyProduct = storeKitService.product(for: .yearlySubscription) {
                        PricingOptionView(
                            title: "Premium Annuel",
                            subtitle: "Facturé annuellement",
                            price: yearlyProduct.displayPrice,
                            badge: "Économisez 18%",
                            priceDetail: storeKitService.yearlyMonthlyEquivalent(),
                            isPopular: true,
                            isLoading: storeKitService.isLoading,
                            action: {
                                Task {
                                    let success = await storeKitService.purchase(yearlyProduct)
                                    if success {
                                        dismiss()
                                    }
                                }
                            }
                        )
                    }
                    
                    // Premium à Vie
                    if let lifetimeProduct = storeKitService.product(for: .lifetimePurchase) {
                        PricingOptionView(
                            title: "Premium à Vie",
                            subtitle: "Achat unique",
                            price: lifetimeProduct.displayPrice,
                            badge: "Une seule fois",
                            isLifetime: true,
                            isLoading: storeKitService.isLoading,
                            action: {
                                Task {
                                    let success = await storeKitService.purchase(lifetimeProduct)
                                    if success {
                                        dismiss()
                                    }
                                }
                            }
                        )
                    }
                }
            }
            
            // Boutons d'action
            VStack(spacing: 12) {
                // Bouton pour ouvrir la vue d'achat complète
                Button("Voir toutes les options") {
                    showFullUpgradeView = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                
                Button("Plus tard") {
                    dismiss()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
        }
        .padding(24)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal, 20)
        .sheet(isPresented: $showFullUpgradeView) {
            PremiumUpgradeView()
        }
        // ✅ Gestion stable de l'apparition/disparition
        .onAppear {
            print("🔒 PremiumUpgradeAlert - Affichage pour: \(feature)")
            print("🔒 StoreKitService - Produits disponibles: \(storeKitService.products.count)")
            print("🔒 StoreKitService - Produits: \(storeKitService.products.map { "\($0.id): \($0.displayPrice)" })")
            
            // Vérifier chaque produit individuellement
            if let monthly = storeKitService.product(for: .monthlySubscription) {
                print("✅ Produit mensuel trouvé: \(monthly.displayPrice)")
            } else {
                print("❌ Produit mensuel NON trouvé")
            }
            
            if let yearly = storeKitService.product(for: .yearlySubscription) {
                print("✅ Produit annuel trouvé: \(yearly.displayPrice)")
            } else {
                print("❌ Produit annuel NON trouvé")
            }
            
            if let lifetime = storeKitService.product(for: .lifetimePurchase) {
                print("✅ Produit lifetime trouvé: \(lifetime.displayPrice)")
            } else {
                print("❌ Produit lifetime NON trouvé")
            }
            
            // Si aucun produit n'est chargé, essayer de les recharger
            if storeKitService.products.isEmpty {
                print("🔄 Aucun produit trouvé, rechargement en cours...")
                Task {
                    await storeKitService.loadProducts()
                }
            }
        }
        // ✅ Suppression d'onDisappear problématique - la popup se ferme naturellement
    }
}

struct PremiumBenefitRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

// MARK: - Vue Premium complète
struct PremiumUpgradeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var freemiumService = FreemiumService.shared
    @ObservedObject private var storeKitService = StoreKitService.shared
    
    private let wheelTrackBlue = Color(red: 0.2, green: 0.7, blue: 1.0)
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header Premium
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("💎 WHEELTRACK PREMIUM")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(wheelTrackBlue)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.yellow.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.yellow, lineWidth: 1)
                                )
                        )
                        
                        Text("Débloquez tout le potentiel de WheelTrack")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Gestion professionnelle avec analytics avancés")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Grille des fonctionnalités
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        
                        FeatureCard(
                            icon: "infinity.circle.fill",
                            title: "Véhicules illimités",
                            subtitle: "Gérez toute votre flotte",
                            color: .blue
                        )
                        
                        FeatureCard(
                            icon: "chart.bar.fill",
                            title: "Analytics Pro",
                            subtitle: "Graphiques détaillés",
                            color: .green
                        )
                        
                        FeatureCard(
                            icon: "key.radiowaves.forward.fill",
                            title: "Module Location",
                            subtitle: "Contrats & revenus",
                            color: .orange
                        )
                        
                        FeatureCard(
                            icon: "doc.text.fill",
                            title: "Export PDF",
                            subtitle: "Rapports complets",
                            color: .red
                        )
                        
                        FeatureCard(
                            icon: "building.2.fill",
                            title: "Garages Pro",
                            subtitle: "Favoris illimités",
                            color: .purple
                        )
                        
                        FeatureCard(
                            icon: "icloud.fill",
                            title: "Sync iCloud",
                            subtitle: "Multi-appareils",
                            color: .indigo
                        )
                    }
                    
                    // Options de pricing
                    VStack(spacing: 16) {
                        // Premium Mensuel
                        if let monthlyProduct = storeKitService.product(for: .monthlySubscription) {
                            PricingOptionView(
                                title: "Premium Mensuel",
                                subtitle: "Facturé mensuellement",
                                price: monthlyProduct.displayPrice,
                                isPopular: false,
                                isLoading: storeKitService.isLoading,
                                action: {
                                    Task {
                                        let success = await storeKitService.purchase(monthlyProduct)
                                        if success {
                                            dismiss()
                                        }
                                    }
                                }
                            )
                        }
                        
                        // Premium Annuel (Populaire)
                        if let yearlyProduct = storeKitService.product(for: .yearlySubscription) {
                            PricingOptionView(
                                title: "Premium Annuel",
                                subtitle: "Facturé annuellement",
                                price: yearlyProduct.displayPrice,
                                badge: "Économisez 18%",
                                priceDetail: storeKitService.yearlyMonthlyEquivalent(),
                                isPopular: true,
                                isLoading: storeKitService.isLoading,
                                action: {
                                    Task {
                                        let success = await storeKitService.purchase(yearlyProduct)
                                        if success {
                                            dismiss()
                                        }
                                    }
                                }
                            )
                        }
                        
                        // Premium à Vie
                        if let lifetimeProduct = storeKitService.product(for: .lifetimePurchase) {
                            PricingOptionView(
                                title: "Premium à Vie",
                                subtitle: "Achat unique",
                                price: lifetimeProduct.displayPrice,
                                badge: "Une seule fois",
                                isLifetime: true,
                                isLoading: storeKitService.isLoading,
                                action: {
                                    Task {
                                        let success = await storeKitService.purchase(lifetimeProduct)
                                        if success {
                                            dismiss()
                                        }
                                    }
                                }
                            )
                        }
                    }
                    
                    // Bouton Restaurer les achats
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
                            .foregroundColor(wheelTrackBlue)
                        }
                    
                    // Bouton temporaire pour tests
                    #if DEBUG
                    if !freemiumService.isPremium {
                        Button {
                            freemiumService.activatePremium()
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "crown.fill")
                                Text("Activer Premium (Test)")
                                Spacer()
                                Text("GRATUIT")
                                    .font(.caption)
                                    .fontWeight(.bold)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [wheelTrackBlue, wheelTrackBlue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    #endif
                    
                    // Footer
                    VStack(spacing: 8) {
                        Text("• Abonnement renouvelé automatiquement")
                        Text("• Annulation possible à tout moment")
                        Text("• Essai gratuit de 7 jours")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 50)
            }
            .background(
                LinearGradient(
                    colors: [wheelTrackBlue.opacity(0.05), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundColor(wheelTrackBlue)
                }
            }
        }
        .onAppear {
            print("🔒 PremiumUpgradeView - Affichage de la vue complète")
            print("🔒 StoreKitService - Produits disponibles: \(storeKitService.products.count)")
            print("🔒 StoreKitService - Produits: \(storeKitService.products.map { "\($0.id): \($0.displayPrice)" })")
            
            // Vérifier chaque produit individuellement
            if let monthly = storeKitService.product(for: .monthlySubscription) {
                print("✅ Produit mensuel trouvé: \(monthly.displayPrice)")
            } else {
                print("❌ Produit mensuel NON trouvé")
            }
            
            if let yearly = storeKitService.product(for: .yearlySubscription) {
                print("✅ Produit annuel trouvé: \(yearly.displayPrice)")
            } else {
                print("❌ Produit annuel NON trouvé")
            }
            
            if let lifetime = storeKitService.product(for: .lifetimePurchase) {
                print("✅ Produit lifetime trouvé: \(lifetime.displayPrice)")
            } else {
                print("❌ Produit lifetime NON trouvé")
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
    }
}

struct PricingOptionView: View {
    let title: String
    let subtitle: String
    let price: String
    let badge: String?
    let priceDetail: String?
    let isPopular: Bool
    let isLifetime: Bool
    let isLoading: Bool
    let action: () -> Void
    
    init(
        title: String,
        subtitle: String,
        price: String,
        badge: String? = nil,
        priceDetail: String? = nil,
        isPopular: Bool = false,
        isLifetime: Bool = false,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.badge = badge
        self.priceDetail = priceDetail
        self.isPopular = isPopular
        self.isLifetime = isLifetime
        self.isLoading = isLoading
        self.action = action
    }
    
    private let wheelTrackBlue = Color(red: 0.2, green: 0.7, blue: 1.0)
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Badge si populaire
                if isPopular {
                    HStack {
                        Spacer()
                        Text("⭐ POPULAIRE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(wheelTrackBlue)
                            .clipShape(Capsule())
                        Spacer()
                    }
                    .padding(.bottom, 8)
                }
                
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(title)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 4) {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Text(price)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    if let badge = badge {
                                        Text(badge)
                                            .font(.caption2)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.green)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(.green.opacity(0.15))
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }
                                }
                            }
                            
                            if let priceDetail = priceDetail, !isLoading {
                                Text(priceDetail)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isPopular ? wheelTrackBlue : (isLifetime ? .purple : Color(.systemGray4)),
                            lineWidth: isPopular || isLifetime ? 2 : 1
                        )
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PremiumUpgradeAlert(feature: .unlimitedVehicles)
} 