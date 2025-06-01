import SwiftUI
import CoreLocation

/// Vue de test pour la géolocalisation - comme dans Maps
struct LocationTestView: View {
    @StateObject private var locationService = LocationService.shared
    @State private var showingLocationDetails = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // En-tête
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.15), .blue.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Géolocalisation")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Test du service de localisation")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Statut actuel
                VStack(spacing: 16) {
                    // Carte de statut
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: statusIcon)
                                .font(.title3)
                                .foregroundColor(statusColor)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Statut")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Text(locationService.locationStatusMessage)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                        }
                        
                        if let location = locationService.currentLocation {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.green)
                                    Text("Position actuelle")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                }
                                
                                Text(locationService.coordinatesText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .monospaced()
                                
                                Text("Précision: \(Int(location.horizontalAccuracy)) m")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                }
                
                // Actions
                VStack(spacing: 16) {
                    // Bouton principal comme dans Maps
                    LocationButton { location in
                        print("✅ Position reçue: \(location.coordinate)")
                        showingLocationDetails = true
                    }
                    
                    // Actions supplémentaires
                    HStack(spacing: 12) {
                        if locationService.isLocationAuthorized {
                            Button("Suivi continu") {
                                print("🔄 Démarrage du suivi continu")
                                locationService.startLocationUpdates()
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                            
                            Button("Arrêter") {
                                print("⏸️ Arrêt du suivi")
                                locationService.stopLocationUpdates()
                            }
                            .buttonStyle(SecondaryActionButtonStyle())
                        } else {
                            Button("Autoriser") {
                                print("🔓 Demande d'autorisation manuelle")
                                locationService.requestLocationPermission()
                            }
                            .buttonStyle(PrimaryActionButtonStyle())
                        }
                    }
                    
                    // Messages d'erreur
                    if let error = locationService.locationError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Informations supplémentaires
                if locationService.isUpdatingLocation {
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        
                        Text("Recherche de votre position...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .navigationTitle("Test Géolocalisation")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Position trouvée", isPresented: $showingLocationDetails) {
                Button("OK") { }
            } message: {
                if let location = locationService.currentLocation {
                    Text("Latitude: \(location.coordinate.latitude, specifier: "%.6f")\nLongitude: \(location.coordinate.longitude, specifier: "%.6f")\nPrécision: \(Int(location.horizontalAccuracy)) mètres")
                }
            }
        }
    }
    
    // MARK: - Propriétés calculées
    
    private var statusIcon: String {
        switch locationService.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "checkmark.circle.fill"
        case .denied, .restricted:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        @unknown default:
            return "exclamationmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch locationService.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .gray
        }
    }
}

// MARK: - Styles de boutons personnalisés

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [.blue, .blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

#Preview {
    LocationTestView()
} 