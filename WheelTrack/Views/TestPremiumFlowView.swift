import SwiftUI

/// Vue de test pour vérifier le flux Premium complet
public struct TestPremiumFlowView: View {
    @StateObject private var freemiumService = FreemiumService.shared
    @State private var showPremiumAlert = false
    @State private var showPurchaseView = false
    @State private var selectedFeature: FreemiumService.PremiumFeature = .unlimitedVehicles
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Status actuel
                    statusSection
                    
                    // Test des fonctionnalités
                    featuresTestSection
                    
                    // Test des vues d'achat
                    purchaseTestSection
                    
                    // Actions de test
                    testActionsSection
                }
                .padding()
            }
            .navigationTitle("Test Flux Premium")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showPremiumAlert) {
            PremiumUpgradeAlert(feature: selectedFeature)
        }
        .sheet(isPresented: $showPurchaseView) {
            PremiumPurchaseView()
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status Actuel")
                .font(.headline)
            
            HStack {
                Circle()
                    .fill(freemiumService.isPremium ? .green : .red)
                    .frame(width: 12, height: 12)
                
                Text(freemiumService.isPremium ? "Premium Actif" : "Version Gratuite")
                    .font(.subheadline)
                
                Spacer()
                
                if freemiumService.isPremium {
                    Text("Type: \(purchaseTypeString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if freemiumService.isPremium {
                Text("✅ Toutes les fonctionnalités sont débloquées")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                Text("⚠️ Certaines fonctionnalités sont limitées")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var featuresTestSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Test des Fonctionnalités")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                FeatureTestCard(
                    feature: .unlimitedVehicles,
                    title: "Véhicules",
                    currentCount: 1,
                    maxFree: freemiumService.maxVehiclesFree
                )
                
                FeatureTestCard(
                    feature: .rentalModule,
                    title: "Locations",
                    currentCount: 0,
                    maxFree: freemiumService.maxRentalsFree
                )
                
                FeatureTestCard(
                    feature: .advancedAnalytics,
                    title: "Analytics",
                    currentCount: 0,
                    maxFree: 0
                )
                
                FeatureTestCard(
                    feature: .garageModule,
                    title: "Garages",
                    currentCount: 0,
                    maxFree: 0
                )
            }
        }
    }
    
    private var purchaseTestSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Test des Vues d'Achat")
                .font(.headline)
            
            VStack(spacing: 8) {
                Button("Alerte Premium (Fonctionnalité bloquée)") {
                    selectedFeature = .unlimitedVehicles
                    showPremiumAlert = true
                }
                .buttonStyle(.bordered)
                
                Button("Vue d'Achat Complète") {
                    showPurchaseView = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var testActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Actions de Test")
                .font(.headline)
            
            VStack(spacing: 8) {
                Button("Activer Premium (Test)") {
                    freemiumService.activatePremium()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.green)
                
                Button("Désactiver Premium") {
                    freemiumService.deactivatePremium()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                
                Button("Test StoreKit") {
                    // Navigation vers StoreKitTestView
                }
                .buttonStyle(.bordered)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var purchaseTypeString: String {
        switch freemiumService.currentPurchaseType {
        case .monthly: return "Mensuel"
        case .yearly: return "Annuel"
        case .lifetime: return "À Vie"
        case .test: return "Test"
        }
    }
}

struct FeatureTestCard: View {
    let feature: FreemiumService.PremiumFeature
    let title: String
    let currentCount: Int
    let maxFree: Int
    
    @ObservedObject private var freemiumService = FreemiumService.shared
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundColor(featureColor)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
            
            if freemiumService.isPremium {
                Text("✅ Illimité")
                    .font(.caption2)
                    .foregroundColor(.green)
            } else {
                Text("\(currentCount)/\(maxFree)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 80)
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(featureColor.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var featureColor: Color {
        if freemiumService.isPremium {
            return .green
        } else if currentCount >= maxFree {
            return .red
        } else {
            return .blue
        }
    }
}

#Preview {
    TestPremiumFlowView()
}
