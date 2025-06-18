import SwiftUI

// MARK: - Floating Action Button Component
public struct FloatingActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    let accessibilityLabel: String
    let accessibilityHint: String
    
    public init(
        icon: String = "plus",
        color: Color = .blue,
        accessibilityLabel: String,
        accessibilityHint: String,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            action()
            
            // Feedback haptique standardisé
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
        }) {
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    LinearGradient(
                        colors: [color, color.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .coloredShadow(color)
        }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Modern Header Component
public struct ModernHeader: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    public init(icon: String, title: String, subtitle: String, color: Color = .blue) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Icône moderne
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.15), color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    @Previewable @AppStorage("app_language") var appLanguage: String = "fr"
    
    func localText(_ key: String) -> String {
        switch (key, appLanguage) {
        case ("vehicles", "en"): return "Vehicles"
        case ("vehicles", _): return "Véhicules"
        case ("manage_fleet", "en"): return "Manage your vehicle fleet"
        case ("manage_fleet", _): return "Gérez votre flotte automobile"
        case ("add_vehicle", "en"): return "Add vehicle"
        case ("add_vehicle", _): return "Ajouter un véhicule"
        case ("tap_to_add", "en"): return "Tap to add a new vehicle"
        case ("tap_to_add", _): return "Touchez pour ajouter un nouveau véhicule"
        default: return key
        }
    }
    
    return VStack(spacing: 30) {
        ModernHeader(
            icon: "car.2.fill",
            title: localText("vehicles"),
            subtitle: localText("manage_fleet"),
            color: .blue
        )
        
        FloatingActionButton(
            accessibilityLabel: localText("add_vehicle"),
            accessibilityHint: localText("tap_to_add")
        ) {
            print("Bouton pressé")
        }
    }
    .padding()
} 