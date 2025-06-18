import SwiftUI
import AuthenticationServices
import Combine

/// Vue d'accueil moderne et engageante pour WheelTrack
public struct WelcomeView: View {
    @ObservedObject private var signInService = AppleSignInService.shared
    @AppStorage("app_language") private var currentLanguage: String = "fr"
    @State private var currentFeatureIndex = 0
    @State private var animateGradient = false
    
    public init() {
        signInService.loadUserIdentifier()
    }
    
    // Helper fonction pour la localisation
    private func localText(_ french: String, _ english: String) -> String {
        return currentLanguage == "en" ? english : french
    }
    
    // Toutes les fonctionnalités de l'app
    private var features: [WheelTrackFeature] {
        [
            WheelTrackFeature(
                icon: "car.2.fill",
                title: localText("Gestion Véhicules", "Vehicle Management"),
                description: localText("Ajoutez et gérez tous vos véhicules", "Add and manage all your vehicles"),
                details: localText("Multi-carburants • Suivi kilométrage • Statut en temps réel", "Multi-fuel • Mileage tracking • Real-time status"),
                color: .blue
            ),
            WheelTrackFeature(
                icon: "creditcard.fill",
                title: localText("Suivi Financier", "Financial Tracking"),
                description: localText("Analytics complètes de vos dépenses", "Complete expense analytics"),
                details: localText("Graphiques • Filtres avancés • Sync CloudKit", "Charts • Advanced filters • CloudKit sync"),
                color: .green
            ),
            WheelTrackFeature(
                icon: "wrench.and.screwdriver.fill",
                title: localText("Maintenance Pro", "Pro Maintenance"),
                description: localText("Planning et historique complets", "Complete planning and history"),
                details: localText("Rappels auto • Coûts détaillés • Planification", "Auto reminders • Detailed costs • Planning"),
                color: .orange
            ),
            WheelTrackFeature(
                icon: "building.2.fill",
                title: localText("Réseau Garages", "Garage Network"),
                description: localText("Trouvez les meilleurs garages", "Find the best garages"),
                details: localText("GPS • Évaluations • Horaires • Services", "GPS • Reviews • Hours • Services"),
                color: .purple
            ),
            WheelTrackFeature(
                icon: "key.radiowaves.forward.fill",
                title: localText("Location Smart", "Smart Rental"),
                description: localText("Générez des revenus facilement", "Generate income easily"),
                details: localText("Contrats • Revenus • Disponibilités • Suivi", "Contracts • Income • Availability • Tracking"),
                color: .cyan
            ),
            WheelTrackFeature(
                icon: "chart.line.uptrend.xyaxis",
                title: localText("Dashboard Analytics", "Analytics Dashboard"),
                description: localText("Vue d'ensemble intelligente", "Smart overview"),
                details: localText("KPIs • Alertes • Performance • Prédictions", "KPIs • Alerts • Performance • Predictions"),
                color: .pink
            )
        ]
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Hero Section avec gradient animé
                heroSection
                
                // Section des fonctionnalités
                featuresSection
                
                // Section authentification
                authenticationSection
                
                // Footer
                footerSection
            }
        }
        .background(backgroundGradient)
        .onAppear {
            startFeatureCarousel()
            startGradientAnimation()
        }
    }
    
    // MARK: - Hero Section
    
    private var heroSection: some View {
        VStack(spacing: 30) {
            Spacer(minLength: 60)
            
            // Logo animé avec effet de pulsation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(animateGradient ? 1.1 : 1.0)
                
                Image(systemName: "car.rear.and.tire.marks")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateGradient)
            
            // Titre principal
            VStack(spacing: 12) {
                Text("WheelTrack")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(localText("L'app complète pour gérer\nvos véhicules comme un pro", "The complete app to manage\nyour vehicles like a pro"))
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            
            // Statistiques impressionnantes
            HStack(spacing: 30) {
                StatCard(number: "6", label: "Modules", icon: "apps.iphone")
                StatCard(number: "∞", label: "Véhicules", icon: "car.fill")
                StatCard(number: "100%", label: "Gratuit", icon: "gift.fill")
            }
            .padding(.top, 20)
            
            Spacer(minLength: 40)
        }
        .padding(.horizontal, 30)
    }
    
    // MARK: - Features Section
    
    private var featuresSection: some View {
        VStack(spacing: 30) {
            // Titre de section
            VStack(spacing: 8) {
                Text("Tout ce dont vous avez besoin")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Une solution complète pour tous vos besoins automobiles")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 30)
            
            // Carrousel de fonctionnalités
            TabView(selection: $currentFeatureIndex) {
                ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                    ModernFeatureCard(feature: feature)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .frame(height: 280)
            .onReceive(Timer.publish(every: 4.0, on: .main, in: .common).autoconnect()) { _ in
                withAnimation(.easeInOut(duration: 0.8)) {
                    currentFeatureIndex = (currentFeatureIndex + 1) % features.count
                }
            }
            
            // Grille compacte des fonctionnalités
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                    CompactFeatureCard(feature: feature, isActive: index == currentFeatureIndex)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentFeatureIndex = index
                            }
                        }
                }
            }
            .padding(.horizontal, 30)
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Authentication Section
    
    private var authenticationSection: some View {
        VStack(spacing: 25) {
            if signInService.userIdentifier == nil {
                VStack(spacing: 20) {
                    Text("Prêt à commencer ?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Connectez-vous en toute sécurité avec Apple")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                                    AppleSignInService.shared.signIn(with: appleIDCredential)
                                }
                            case .failure(let error):
                                print("Erreur de connexion: \(error.localizedDescription)")
                            }
                        }
                    )
                    .frame(height: 55)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Avantages de la connexion
                    HStack(spacing: 20) {
                        BenefitBadge(icon: "icloud.fill", text: "Sync Cloud")
                        BenefitBadge(icon: "lock.shield.fill", text: "Sécurisé")
                        BenefitBadge(icon: "devices", text: "Multi-appareils")
                    }
                }
            } else {
                VStack(spacing: 20) {
                    Text("Vous êtes connecté !")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Button("Se déconnecter") {
                        withAnimation {
                            signInService.signOut()
                        }
                    }
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(16)
                    .fontWeight(.semibold)
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 20)
    }
    
    // MARK: - Footer Section
    
    private var footerSection: some View {
        VStack(spacing: 15) {
            Text("En continuant, vous acceptez nos conditions d'utilisation")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("WheelTrack • Votre partenaire automobile")
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.7))
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 40)
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color.blue.opacity(0.02),
                Color.cyan.opacity(0.01)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Animation Methods
    
    private func startFeatureCarousel() {
        // Le carousel se gère automatiquement avec le Timer dans featuresSection
    }
    
    private func startGradientAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            animateGradient = true
        }
    }
}

// MARK: - Supporting Models & Views

/// Modèle pour représenter une fonctionnalité de WheelTrack
struct WheelTrackFeature {
    let icon: String
    let title: String
    let description: String
    let details: String
    let color: Color
}

/// Carte de statistique pour le hero
struct StatCard: View {
    let number: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 80)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.7))
        )
    }
}

/// Carte moderne pour les fonctionnalités principales
struct ModernFeatureCard: View {
    let feature: WheelTrackFeature
    
    var body: some View {
        VStack(spacing: 20) {
            // Icône avec gradient
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [feature.color.opacity(0.2), feature.color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: feature.icon)
                    .font(.title)
                    .foregroundColor(feature.color)
            }
            
            VStack(spacing: 8) {
                Text(feature.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(feature.details)
                    .font(.caption)
                    .foregroundColor(feature.color)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: feature.color.opacity(0.1), radius: 15, x: 0, y: 8)
        )
        .padding(.horizontal, 20)
    }
}

/// Carte compacte pour la grille des fonctionnalités
struct CompactFeatureCard: View {
    let feature: WheelTrackFeature
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundColor(isActive ? feature.color : .secondary)
                .scaleEffect(isActive ? 1.1 : 1.0)
            
            Text(feature.title)
                .font(.caption)
                .fontWeight(isActive ? .semibold : .medium)
                .foregroundColor(isActive ? .primary : .secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? feature.color.opacity(0.1) : Color(.systemGray6).opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isActive ? feature.color.opacity(0.3) : .clear, lineWidth: 1)
                )
        )
        .animation(.easeInOut(duration: 0.3), value: isActive)
    }
}

/// Badge pour les avantages de la connexion
struct BenefitBadge: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
            
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.blue.opacity(0.1))
        )
    }
}

/// Ancienne FeatureRow pour compatibilité (si utilisée ailleurs)
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 30)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    WelcomeView()
} 