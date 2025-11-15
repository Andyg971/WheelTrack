import SwiftUI
import StoreKit

/// Alerte moderne pour proposer l'upgrade vers Premium
struct PremiumUpgradeAlert: View {
    let feature: FreemiumService.PremiumFeature
    @ObservedObject private var freemiumService = FreemiumService.shared
    @ObservedObject private var storeKitService = StoreKitService.shared
    @ObservedObject private var localizationService = LocalizationService.shared
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
                
                Text(L(CommonTranslations.premiumRequired))
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
                        text: L(CommonTranslations.unlimitedVehicles),
                        color: .blue
                    )
                    
                    PremiumBenefitRow(
                        icon: "chart.bar.xaxis",
                        text: L(CommonTranslations.professionalAnalytics),
                        color: .green
                    )
                    
                    PremiumBenefitRow(
                        icon: "key.radiowaves.forward.fill",
                        text: L(CommonTranslations.fullRentalModule),
                        color: .orange
                    )
                    
                    PremiumBenefitRow(
                        icon: "icloud.fill",
                        text: L(CommonTranslations.iCloudSync),
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
                                        // ✅ Mode démo pour captures d'écran App Store (remplace les produits vides)
                        if storeKitService.products.isEmpty {
                            // Afficher des options de pricing démo avec vrais prix
                            VStack(spacing: 12) {
                                DemoPricingOptionView(
                                    title: L(CommonTranslations.monthlyPremium),
                                    subtitle: L(CommonTranslations.billedMonthly),
                                    price: localizationService.currentLanguage == "en" ? "$3.99" : "4,99 €",
                                    originalPrice: nil
                                ) {
                                    // Action démo pour capture d'écran
                                }
                                
                                DemoPricingOptionView(
                                    title: L(CommonTranslations.yearlyPremium),
                                    subtitle: L(CommonTranslations.save17Percent),
                                    price: localizationService.currentLanguage == "en" ? "$39.99" : "49,99 €",
                                    originalPrice: localizationService.currentLanguage == "en" ? "$47.88" : "59,88 €",
                                    isPopular: true
                                ) {
                                    // Action démo pour capture d'écran
                                }
                                
                                DemoPricingOptionView(
                                    title: L(CommonTranslations.lifetimePremium),
                                    subtitle: L(CommonTranslations.oneTimePurchaseAccess),
                                    price: localizationService.currentLanguage == "en" ? "$79.99" : "79,99 €",
                                    originalPrice: nil
                                ) {
                                    // Action démo pour capture d'écran
                                }
                            }
                            

                    .padding()
                    .frame(maxWidth: .infinity)
                } else {
                    // Premium Mensuel
                    if let monthlyProduct = storeKitService.product(for: .monthlySubscription) {
                        PricingOptionView(
                            title: L(CommonTranslations.monthlyPremium),
                            subtitle: L(CommonTranslations.billedMonthly),
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
                            title: L(CommonTranslations.yearlyPremium),
                            subtitle: L(CommonTranslations.billedYearly),
                            price: yearlyProduct.displayPrice,
                            badge: L(CommonTranslations.save18Percent),
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
                            title: L(CommonTranslations.lifetimePremium),
                            subtitle: L(CommonTranslations.oneTimePurchase),
                            price: lifetimeProduct.displayPrice,
                            badge: L(CommonTranslations.premiumBadge),
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
                Button(L(CommonTranslations.seeAllOptions)) {
                    showFullUpgradeView = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                
                Button(L(CommonTranslations.later)) {
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
    @ObservedObject private var localizationService = LocalizationService.shared
    
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
                            Text(L(CommonTranslations.wheeltrackPremium))
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
                        
                        Text(L(CommonTranslations.unlockFullPotential))
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(L(CommonTranslations.professionalManagement))
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
                            title: L(CommonTranslations.unlimitedVehicles),
                            subtitle: L(CommonTranslations.manageFleetText),
                            color: .blue
                        )
                        
                        FeatureCard(
                            icon: "chart.bar.fill",
                            title: L(CommonTranslations.analyticsPro),
                            subtitle: L(CommonTranslations.detailedGraphs),
                            color: .green
                        )
                        
                        FeatureCard(
                            icon: "key.radiowaves.forward.fill",
                            title: L(CommonTranslations.rentalModule),
                            subtitle: L(CommonTranslations.contractsRevenue),
                            color: .orange
                        )
                        
                        FeatureCard(
                            icon: "doc.text.fill",
                            title: L(CommonTranslations.exportPdf),
                            subtitle: L(CommonTranslations.completeReports),
                            color: .red
                        )
                        
                        FeatureCard(
                            icon: "building.2.fill",
                            title: L(CommonTranslations.garagesPro),
                            subtitle: L(CommonTranslations.unlimitedFavorites),
                            color: .purple
                        )
                        
                        FeatureCard(
                            icon: "icloud.fill",
                            title: L(CommonTranslations.syncIcloud),
                            subtitle: L(CommonTranslations.multiDevice),
                            color: .indigo
                        )
                    }
                    
                    // Options de pricing
                    VStack(spacing: 16) {
                        // Premium Mensuel
                        if let monthlyProduct = storeKitService.product(for: .monthlySubscription) {
                            PricingOptionView(
                                title: L(CommonTranslations.monthlyPremium),
                                subtitle: L(CommonTranslations.billedMonthly),
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
                                title: L(CommonTranslations.yearlyPremium),
                                subtitle: L(CommonTranslations.billedYearly),
                                price: yearlyProduct.displayPrice,
                                badge: L(CommonTranslations.save18Percent),
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
                                title: L(CommonTranslations.lifetimePremium),
                                subtitle: L(CommonTranslations.oneTimePurchase),
                                price: lifetimeProduct.displayPrice,
                                badge: L(CommonTranslations.premiumBadge),
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
                                Text(L(CommonTranslations.restorePurchases))
                            }
                            .font(.subheadline)
                            .foregroundColor(wheelTrackBlue)
                        }
                    

                    
                    // Footer
                    VStack(spacing: 8) {
                        Text(L(CommonTranslations.autoRenewSubscription))
                        Text(L(CommonTranslations.cancelAnytime))
                        Text(L(CommonTranslations.freeTrial7Days))
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
            .navigationTitle(L(CommonTranslations.premiumBadge))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L(CommonTranslations.close)) {
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



// MARK: - Demo Pricing Option (App Store Screenshots)
struct DemoPricingOptionView: View {
    let title: String
    let subtitle: String
    let price: String
    let originalPrice: String?
    let isPopular: Bool
    let action: () -> Void
    
    init(
        title: String,
        subtitle: String,
        price: String,
        originalPrice: String? = nil,
        isPopular: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.price = price
        self.originalPrice = originalPrice
        self.isPopular = isPopular
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
                        Text(L(CommonTranslations.popularBadge))
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
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            if let originalPrice = originalPrice {
                                Text(originalPrice)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .strikethrough()
                            }
                            
                            Text(price)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isPopular ? wheelTrackBlue : Color(.systemGray4), lineWidth: isPopular ? 2 : 1)
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
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
                        Text(L(CommonTranslations.popularBadge))
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