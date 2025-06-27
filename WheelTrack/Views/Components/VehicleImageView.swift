import SwiftUI

// MARK: - Vehicle Image View Component
struct VehicleImageView: View {
    let vehicle: Vehicle
    let size: ImageSize
    
    @StateObject private var imageManager = ImageManager.shared
    @State private var loadedImage: UIImage?
    
    enum ImageSize {
        case small      // 60x45 - pour les listes
        case medium     // 120x90 - pour les cartes
        case large      // 200x150 - pour les détails
        case fullWidth  // largeur complète - pour les headers
        
        var dimensions: CGSize {
            switch self {
            case .small:
                return CGSize(width: 60, height: 45)
            case .medium:
                return CGSize(width: 120, height: 90)
            case .large:
                return CGSize(width: 200, height: 150)
            case .fullWidth:
                return CGSize(width: UIScreen.main.bounds.width - 32, height: 200)
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small:
                return 6
            case .medium:
                return 8
            case .large, .fullWidth:
                return 12
            }
        }
    }
    
    var body: some View {
        Group {
            if let loadedImage = loadedImage {
                // Affichage de l'image réelle
                Image(uiImage: loadedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.dimensions.width, height: size.dimensions.height)
                    .clipped()
                    .cornerRadius(size.cornerRadius)
            } else {
                // Placeholder avec informations du véhicule
                VehiclePlaceholder(vehicle: vehicle, size: size)
            }
        }
        .onAppear {
            loadVehicleImage()
        }
        .onChange(of: vehicle.mainImageURL) { _, _ in
            loadVehicleImage()
        }
    }
    
    private func loadVehicleImage() {
        guard let imageURL = vehicle.mainImageURL else {
            loadedImage = nil
            return
        }
        
        loadedImage = imageManager.loadImage(fileName: imageURL, from: .vehicle)
    }
}

// MARK: - Vehicle Placeholder
private struct VehiclePlaceholder: View {
    let vehicle: Vehicle
    let size: VehicleImageView.ImageSize
    
    private var vehicleIcon: String {
        switch vehicle.fuelType {
        case .electric:
            return "bolt.car"
        case .hybrid:
            return "leaf.circle"
        default:
            return "car"
        }
    }
    
    private var gradientColors: [Color] {
        switch vehicle.color.lowercased() {
        case "rouge", "red":
            return [Color.red.opacity(0.3), Color.red.opacity(0.1)]
        case "bleu", "blue":
            return [Color.blue.opacity(0.3), Color.blue.opacity(0.1)]
        case "vert", "green":
            return [Color.green.opacity(0.3), Color.green.opacity(0.1)]
        case "noir", "black":
            return [Color.black.opacity(0.3), Color.gray.opacity(0.1)]
        case "blanc", "white":
            return [Color.gray.opacity(0.2), Color.gray.opacity(0.05)]
        case "gris", "gray", "grey":
            return [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]
        case "jaune", "yellow":
            return [Color.yellow.opacity(0.3), Color.yellow.opacity(0.1)]
        case "orange":
            return [Color.orange.opacity(0.3), Color.orange.opacity(0.1)]
        case "violet", "purple":
            return [Color.purple.opacity(0.3), Color.purple.opacity(0.1)]
        default:
            return [Color.blue.opacity(0.2), Color.blue.opacity(0.05)]
        }
    }
    
    var body: some View {
        ZStack {
            // Gradient de fond basé sur la couleur du véhicule
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 4) {
                // Icône du véhicule
                Image(systemName: vehicleIcon)
                    .font(iconFont)
                    .foregroundColor(.primary.opacity(0.6))
                
                if size != .small {
                    // Informations du véhicule pour les tailles moyennes et grandes
                    Text(vehicle.brand)
                        .font(brandFont)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(vehicle.model)
                        .font(modelFont)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: size.dimensions.width, height: size.dimensions.height)
        .cornerRadius(size.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
    
    private var iconFont: Font {
        switch size {
        case .small:
            return .caption
        case .medium:
            return .title3
        case .large, .fullWidth:
            return .largeTitle
        }
    }
    
    private var brandFont: Font {
        switch size {
        case .small:
            return .caption2
        case .medium:
            return .caption
        case .large, .fullWidth:
            return .headline
        }
    }
    
    private var modelFont: Font {
        switch size {
        case .small:
            return .caption2
        case .medium:
            return .caption2
        case .large, .fullWidth:
            return .subheadline
        }
    }
}

// MARK: - Preview
#Preview("With Image") {
    VStack(spacing: 20) {
        VehicleImageView(
            vehicle: Vehicle(
                brand: "BMW",
                model: "X3",
                year: 2023,
                licensePlate: "AB-123-CD",
                mileage: 15000,
                fuelType: .gasoline,
                transmission: .automatic,
                color: "Noir",
                purchaseDate: Date(),
                purchasePrice: 45000,
                purchaseMileage: 0
            ),
            size: .small
        )
        
        VehicleImageView(
            vehicle: Vehicle(
                brand: "Tesla",
                model: "Model 3",
                year: 2023,
                licensePlate: "EL-456-EC",
                mileage: 5000,
                fuelType: .electric,
                transmission: .automatic,
                color: "Rouge",
                purchaseDate: Date(),
                purchasePrice: 65000,
                purchaseMileage: 0
            ),
            size: .medium
        )
        
        VehicleImageView(
            vehicle: Vehicle(
                brand: "Toyota",
                model: "Prius",
                year: 2022,
                licensePlate: "HY-789-BR",
                mileage: 25000,
                fuelType: .hybrid,
                transmission: .automatic,
                color: "Bleu",
                purchaseDate: Date(),
                purchasePrice: 35000,
                purchaseMileage: 0
            ),
            size: .large
        )
    }
    .padding()
} 