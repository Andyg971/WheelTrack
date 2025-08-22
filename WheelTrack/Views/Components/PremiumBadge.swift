import SwiftUI

/// Badge Premium pour identifier les fonctionnalités payantes
struct PremiumBadge: View {
    let size: BadgeSize
    let showText: Bool
    
    enum BadgeSize {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 12
            case .medium: return 16
            case .large: return 20
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }
        
        var padding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
    }
    
    init(size: BadgeSize = .medium, showText: Bool = true) {
        self.size = size
        self.showText = showText
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: size.iconSize))
                .foregroundColor(.yellow)
            
            if showText {
                Text("PREMIUM")
                    .font(size.fontSize)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
            }
        }
        .padding(.horizontal, size.padding)
        .padding(.vertical, size.padding * 0.7)
        .background(
            RoundedRectangle(cornerRadius: size.padding * 2)
                .fill(.yellow.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: size.padding * 2)
                        .stroke(.yellow, lineWidth: 0.5)
                )
        )
    }
}

/// Badge Lock pour les fonctionnalités verrouillées
struct LockedFeatureBadge: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                Text("PRO")
                    .font(.caption2)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// Overlay pour masquer le contenu Premium
struct PremiumOverlay: View {
    let feature: FreemiumService.PremiumFeature
    @ObservedObject private var freemiumService = FreemiumService.shared
    @State private var showUpgradeAlert = false
    
    var body: some View {
        if !freemiumService.hasAccess(to: feature) {
            ZStack {
                // Arrière-plan flou
                Rectangle()
                    .fill(.regularMaterial)
                    .overlay(
                        Rectangle()
                            .fill(.black.opacity(0.1))
                    )
                
                // Contenu de l'overlay
                VStack(spacing: 16) {
                    Image(systemName: feature.icon)
                        .font(.title)
                        .foregroundColor(.blue)
                    
                    Text(feature.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text("Disponible avec Premium")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        showUpgradeAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "crown.fill")
                            Text("Débloquer")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding()
            }
            .sheet(isPresented: $showUpgradeAlert) {
                PremiumUpgradeAlert(feature: feature)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PremiumBadge(size: .small)
        PremiumBadge(size: .medium)
        PremiumBadge(size: .large)
        
        LockedFeatureBadge {
            print("Tapped locked feature")
        }
        
        ZStack {
            Rectangle()
                .fill(.blue.opacity(0.3))
                .frame(height: 200)
            
            Text("Contenu Premium Masqué")
                .font(.title2)
            
            PremiumOverlay(feature: .advancedAnalytics)
        }
    }
    .padding()
} 