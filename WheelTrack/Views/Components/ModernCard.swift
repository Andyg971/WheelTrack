import SwiftUI

// MARK: - Modern Card Component
/// Composant de carte moderne réutilisable avec styles cohérents
public struct ModernCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    let shadowStyle: ShadowStyle
    
    public enum ShadowStyle {
        case light   // radius: 4, y: 2
        case medium  // radius: 8, y: 4  
        case strong  // radius: 12, y: 6
        case none
        
        var radius: CGFloat {
            switch self {
            case .light: return 4
            case .medium: return 8
            case .strong: return 12
            case .none: return 0
            }
        }
        
        var yOffset: CGFloat {
            switch self {
            case .light: return 2
            case .medium: return 4
            case .strong: return 6
            case .none: return 0
            }
        }
    }
    
    public init(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 12,
        shadowStyle: ShadowStyle = .medium,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadowStyle
    }
    
    public var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: shadowStyle == .none ? .clear : .black.opacity(0.05),
                        radius: shadowStyle.radius,
                        x: 0,
                        y: shadowStyle.yOffset
                    )
            )
    }
}

// MARK: - Info Card Component
/// Carte d'information spécialisée avec icône et titre
public struct InfoCard<Content: View>: View {
    let icon: String
    let title: String
    let content: Content
    let iconColor: Color
    
    public init(
        icon: String,
        title: String,
        iconColor: Color = .blue,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.iconColor = iconColor
        self.content = content()
    }
    
    public var body: some View {
        ModernCard(shadowStyle: .medium) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(iconColor)
                        .frame(width: 24, height: 24)
                    
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                content
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ModernCard(shadowStyle: .light) {
            Text("Carte légère")
        }
        
        ModernCard(shadowStyle: .medium) {
            Text("Carte moyenne")
        }
        
        ModernCard(shadowStyle: .strong) {
            Text("Carte forte")
        }
        
        InfoCard(icon: "car.fill", title: "Véhicule", iconColor: .blue) {
            Text("Contenu de la carte véhicule")
        }
    }
    .padding()
} 