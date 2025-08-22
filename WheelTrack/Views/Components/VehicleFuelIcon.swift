import SwiftUI

/// Composant pour afficher l'icône colorée du type de carburant
struct VehicleFuelIcon: View {
    let fuelType: FuelType
    let size: IconSize
    
    enum IconSize {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 24
            case .large: return 32
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .caption
            case .medium: return .body
            case .large: return .title2
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Arrière-plan avec gradient
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            fuelType.color.opacity(0.8),
                            fuelType.color.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size.dimension, height: size.dimension)
                .shadow(color: fuelType.color.opacity(0.3), radius: 2, x: 0, y: 1)
            
            // Icône du carburant
            Image(systemName: fuelType.icon)
                .font(size.font.weight(.bold))
                .foregroundColor(.white)
        }
    }
}

/// Composant plus expressif avec icônes distinctives pour chaque type de carburant
struct ExpressiveFuelTypeIcon: View {
    let fuelType: FuelType
    let size: IconSize
    
    enum IconSize {
        case small, medium, large, extraLarge
        
        var dimension: CGFloat {
            switch self {
            case .small: return 28
            case .medium: return 36
            case .large: return 48
            case .extraLarge: return 64
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .body
            case .medium: return .title3
            case .large: return .title2
            case .extraLarge: return .largeTitle
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 10
            case .large: return 12
            case .extraLarge: return 16
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Fond avec forme distinctive selon le type
            backgroundShape
                .frame(width: size.dimension, height: size.dimension)
                .shadow(color: fuelType.color.opacity(0.4), radius: 4, x: 0, y: 2)
            
            // Icône distinctive
            Image(systemName: iconForType)
                .font(size.font.weight(.semibold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
        }
    }
    
    @ViewBuilder
    private var backgroundShape: some View {
        switch fuelType {
        case .electric:
            RoundedRectangle(cornerRadius: size.cornerRadius) // Moderne/tech
                .fill(backgroundGradient)
        case .gasoline:
            Circle() // Classique
                .fill(backgroundGradient)
        case .diesel:
            RoundedRectangle(cornerRadius: 4) // Industriel/carré
                .fill(backgroundGradient)
        case .hybrid:
            Capsule() // Fluide/oval
                .fill(backgroundGradient)
        case .lpg:
            RoundedRectangle(cornerRadius: size.cornerRadius / 2) // Mixte
                .fill(backgroundGradient)
        }
    }
    
    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                fuelType.color,
                fuelType.color.opacity(0.7),
                fuelType.color.opacity(0.9)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var iconForType: String {
        switch fuelType {
        case .electric:
            return "bolt.circle.fill" // Éclair dans cercle
        case .gasoline:
            return "drop.triangle.fill" // Goutte triangulaire
        case .diesel:
            return "fuelpump.fill" // Pompe à essence
        case .hybrid:
            return "leaf.arrow.circlepath" // Feuille avec recyclage
        case .lpg:
            return "flame.fill" // Flamme
        }
    }
}

/// Composant pour afficher l'icône du véhicule avec indicateur de carburant
struct VehicleWithFuelIcon: View {
    let fuelType: FuelType
    let size: IconSize
    
    enum IconSize {
        case small, medium, large
        
        var vehicleDimension: CGFloat {
            switch self {
            case .small: return 28
            case .medium: return 36
            case .large: return 48
            }
        }
        
        var fuelDimension: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 18
            case .large: return 24
            }
        }
        
        var vehicleFont: Font {
            switch self {
            case .small: return .body
            case .medium: return .title3
            case .large: return .title
            }
        }
        
        var fuelFont: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .body
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Icône du véhicule
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(.systemGray5),
                                Color(.systemGray6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size.vehicleDimension, height: size.vehicleDimension)
                
                Image(systemName: fuelType.vehicleIcon)
                    .font(size.vehicleFont.weight(.medium))
                    .foregroundColor(.primary)
            }
            
            // Indicateur de carburant en bas à droite
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                fuelType.color.opacity(0.9),
                                fuelType.color.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size.fuelDimension, height: size.fuelDimension)
                    .shadow(color: fuelType.color.opacity(0.4), radius: 2, x: 0, y: 1)
                
                Image(systemName: fuelType.icon)
                    .font(size.fuelFont.weight(.bold))
                    .foregroundColor(.white)
            }
            .offset(x: 2, y: 2)
        }
    }
}

/// Composant pour les sélecteurs avec icônes expressives
struct FuelTypeSelectorIcon: View {
    let fuelType: FuelType
    let isSelected: Bool
    
    private let size: CGFloat = 32
    
    var body: some View {
        HStack(spacing: 12) {
            // Icône expressive
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: isSelected ? 
                                [fuelType.color, fuelType.color.opacity(0.8)] :
                                [Color(.systemGray5), Color(.systemGray6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .shadow(
                        color: isSelected ? fuelType.color.opacity(0.3) : .clear,
                        radius: isSelected ? 4 : 0,
                        x: 0, y: 2
                    )
                
                Image(systemName: fuelType.formIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .secondary)
            }
            
            // Texte avec couleur conditionnelle
            Text(fuelType.rawValue)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? fuelType.color : .primary)
        }
    }
}

// MARK: - Previews
#Preview("Fuel Icons") {
    VStack(spacing: 30) {
        Text("Icônes simples")
            .font(.headline)
        
        HStack(spacing: 15) {
            ForEach(FuelType.allCases, id: \.self) { fuelType in
                VStack(spacing: 8) {
                    VehicleFuelIcon(fuelType: fuelType, size: .medium)
                    Text(fuelType.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        
        Divider()
        
        Text("Icônes expressives")
            .font(.headline)
        
        HStack(spacing: 15) {
            ForEach(FuelType.allCases, id: \.self) { fuelType in
                VStack(spacing: 8) {
                    ExpressiveFuelTypeIcon(fuelType: fuelType, size: .medium)
                    Text(fuelType.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        
        Divider()
        
        Text("Sélecteurs de formulaire")
            .font(.headline)
        
        VStack(spacing: 8) {
            ForEach(FuelType.allCases, id: \.self) { fuelType in
                FuelTypeSelectorIcon(fuelType: fuelType, isSelected: fuelType == .electric)
                    .padding(.horizontal)
            }
        }
    }
    .padding()
} 