import SwiftUI
import StoreKit

/// Vue de confirmation affichée après un achat réussi
struct PurchaseSuccessView: View {
    let purchaseType: FreemiumService.PurchaseType
    let productID: String
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    @StateObject private var storeKitService = StoreKitService.shared
    
    var body: some View {
        ZStack {
            // Arrière-plan avec effet de flou
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Contenu principal
            VStack(spacing: 24) {
                // Animation de succès
                successAnimationView
                
                // Détails de l'abonnement
                VStack(spacing: 16) {
                    subscriptionDetailsCard
                    premiumFeaturesCard
                }
                
                // Bouton de fermeture
                Button("Parfait, continuer !") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .font(.headline)
                .fontWeight(.semibold)
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .padding(20)
            .scaleEffect(isAnimating ? 1.0 : 0.7)
            .opacity(isAnimating ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
    
    private var successAnimationView: some View {
        VStack(spacing: 16) {
            ZStack {
                // Cercle de fond avec gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 80, height: 80)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: isAnimating)
                
                // Icône de validation
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.0 : 0.3)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.4), value: isAnimating)
            }
            
            VStack(spacing: 8) {
                Text("🎉 Félicitations !")
                    .font(.title2)
                    .fontWeight(.bold)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6).delay(0.6), value: isAnimating)
                
                Text(successMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.6).delay(0.8), value: isAnimating)
            }
        }
    }
    
    private var subscriptionDetailsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundColor(.yellow)
                    .font(.system(size: 16))
                
                Text("WheelTrack Premium")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("ACTIF")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.green)
                    .clipShape(Capsule())
            }
            
            Divider()
            
            VStack(spacing: 8) {
                HStack {
                    Text("Type d'abonnement:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(subscriptionTypeDescription)
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Prix payé:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(priceDescription)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                if purchaseType != .lifetime {
                    HStack {
                        Text("Renouvellement:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(renewalDescription)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var premiumFeaturesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🚀 Vous avez maintenant accès à:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                FeatureRow(icon: "car.2.fill", text: "Véhicules illimités", color: .blue)
                FeatureRow(icon: "chart.bar.xaxis", text: "Analytics avancés", color: .purple)
                FeatureRow(icon: "key.radiowaves.forward.fill", text: "Module Location complet", color: .orange)
                FeatureRow(icon: "building.2.fill", text: "Garages favoris", color: .green)
                FeatureRow(icon: "doc.text.fill", text: "Export PDF", color: .red)
                FeatureRow(icon: "icloud.fill", text: "Synchronisation iCloud", color: .cyan)
                FeatureRow(icon: "bell.fill", text: "Rappels illimités", color: .yellow)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.08), .purple.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        )
    }
    
    // MARK: - Computed Properties
    
    private var successMessage: String {
        switch purchaseType {
        case .monthly:
            return "Votre abonnement Premium mensuel est maintenant actif"
        case .yearly:
            return "Votre abonnement Premium annuel est maintenant actif"
        case .lifetime:
            return "Votre achat Premium à vie est maintenant actif"
        case .test:
            return "Votre Premium de test est maintenant actif"
        }
    }
    
    private var subscriptionTypeDescription: String {
        switch purchaseType {
        case .monthly:
            return "Premium Mensuel"
        case .yearly:
            return "Premium Annuel"
        case .lifetime:
            return "Premium à Vie"
        case .test:
            return "Premium (Test)"
        }
    }
    
    private var priceDescription: String {
        // Récupérer le prix réel depuis StoreKit si disponible
        switch purchaseType {
        case .monthly:
            if let product = storeKitService.product(for: .monthlySubscription) {
                return product.displayPrice
            }
            return "4,99€" // Fallback
        case .yearly:
            if let product = storeKitService.product(for: .yearlySubscription) {
                return product.displayPrice
            }
            return "49,99€" // Fallback
        case .lifetime:
            if let product = storeKitService.product(for: .lifetimePurchase) {
                return product.displayPrice
            }
            return "19,99€" // Fallback
        case .test:
            return "Gratuit"
        }
    }
    
    private var renewalDescription: String {
        switch purchaseType {
        case .monthly:
            return "Automatique (mensuel)"
        case .yearly:
            return "Automatique (annuel)"
        case .lifetime:
            return "Aucun"
        case .test:
            return "N/A"
        }
    }
}

// MARK: - Feature Row Component

struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 28, height: 28)
                
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(color)
            }
            
            Text(text)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.green)
                .opacity(isVisible ? 1.0 : 0.0)
                .scaleEffect(isVisible ? 1.0 : 0.5)
        }
        .opacity(isVisible ? 1.0 : 0.3)
        .onAppear {
            let randomDelay = Double.random(in: 0.2...0.8)
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(randomDelay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    PurchaseSuccessView(purchaseType: .yearly, productID: "wheeltrack_premium_yearly")
}
