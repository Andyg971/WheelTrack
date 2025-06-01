import SwiftUI
import MapKit
import CoreLocation

public struct GaragesView: View {
    @StateObject private var viewModel = GaragesViewModel()
    @StateObject private var locationService = LocationService.shared
    @State private var showingMap = true  // Afficher la carte par défaut
    @State private var selectedGarageOnMap: Garage? = nil
    @State private var favoriteGarages: Set<String> = []  // IDs des garages favoris

    public init() {
        // Charger les favoris depuis UserDefaults
        if let saved = UserDefaults.standard.object(forKey: "favoriteGarages") as? [String] {
            _favoriteGarages = State<Set<String>>(initialValue: Set(saved))
        }
    }
    
    public var body: some View {
        NavigationStack {
            GaragesMainView(
                showingMap: $showingMap,
                favoriteGarages: $favoriteGarages,
                locationService: locationService,
                viewModel: viewModel,
                onToggleFavorite: toggleFavorite
            )
            .navigationTitle(showingMap ? "Garages à proximité" : "Mes Garages")
            .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingMap.toggle()
                        }
                    } label: {
                        Image(systemName: showingMap ? "list.bullet" : "map")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                LinearGradient(
                                    colors: [Color.green, Color.green.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .accessibilityIdentifier("toggleViewButton")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print("🔘 Bouton géolocalisation tapé - Statut actuel: \(locationService.authorizationStatus)")
                        
                        switch locationService.authorizationStatus {
                        case .denied, .restricted:
                            print("📱 Ouverture des Réglages car autorisation refusée")
                            locationService.requestLocationPermission()
                        case .notDetermined:
                            print("📍 Première demande d'autorisation")
                            locationService.requestLocationPermission()
                        case .authorizedWhenInUse, .authorizedAlways:
                            print("✅ Autorisation accordée - Force la mise à jour")
                            locationService.getCurrentLocation()
                        @unknown default:
                            print("❓ Statut inconnu - Reset complet")
                            locationService.requestLocationPermission()
                        }
                    } label: {
                        Image(systemName: getLocationButtonIcon())
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                LinearGradient(
                                    colors: getLocationButtonColors(),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: getLocationButtonColors().first?.opacity(0.3) ?? .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            .rotationEffect(.degrees(locationService.isUpdatingLocation ? 360 : 0))
                            .animation(locationService.isUpdatingLocation ? .linear(duration: 2).repeatForever(autoreverses: false) : .default, value: locationService.isUpdatingLocation)
                    }
                    .accessibilityIdentifier("locationButton")
                }
            }
            .onAppear {
                print("📱 GaragesView apparue - VÉRIFICATION GÉOLOCALISATION")
                
                // Force immédiate de la demande d'autorisation selon le statut
                let status = locationService.authorizationStatus
                print("🔍 Statut au démarrage: \(status.rawValue)")
                
                switch status {
                case .notDetermined:
                    print("📍 Première demande d'autorisation...")
                    locationService.requestLocationPermission()
                case .denied, .restricted:
                    print("❌ Autorisation refusée précédemment")
                    locationService.locationError = "🔴 Allez dans Réglages > Confidentialité > Localisation > WheelTrack pour autoriser"
                case .authorizedWhenInUse, .authorizedAlways:
                    print("✅ Déjà autorisé - Démarrage géolocalisation")
                    locationService.startLocationUpdates()
                @unknown default:
                    print("❓ Statut inconnu - Tentative d'autorisation")
                    locationService.requestLocationPermission()
                }
            }
            .onDisappear {
                // Arrêter la géolocalisation pour économiser la batterie
                if !showingMap {
                    locationService.stopLocationUpdates()
                    print("📱 GaragesView disparue - Arrêt géolocalisation")
                }
            }
        }
    }
    
    // MARK: - Favorite Management
    
    private func toggleFavorite(_ garage: Garage) {
        let garageId = garage.id.uuidString
        
        if favoriteGarages.contains(garageId) {
            favoriteGarages.remove(garageId)
        } else {
            favoriteGarages.insert(garageId)
        }
        
        // Sauvegarder dans UserDefaults
        UserDefaults.standard.set(Array(favoriteGarages), forKey: "favoriteGarages")
        
        // Animation de feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Helper Functions for Location Button
    
    private func getLocationButtonIcon() -> String {
        switch locationService.authorizationStatus {
        case .denied, .restricted:
            return "location.slash.fill"
        case .notDetermined:
            return "location.fill"
        case .authorizedWhenInUse, .authorizedAlways:
            return locationService.isUpdatingLocation ? "location.circle" : "location.fill"
        @unknown default:
            return "location.fill"
        }
    }
    
    private func getLocationButtonColors() -> [Color] {
        switch locationService.authorizationStatus {
        case .denied, .restricted:
            return [Color.red, Color.red.opacity(0.8)]
        case .notDetermined:
            return [Color.orange, Color.orange.opacity(0.8)]
        case .authorizedWhenInUse, .authorizedAlways:
            return [Color.blue, Color.blue.opacity(0.8)]
        @unknown default:
            return [Color.gray, Color.gray.opacity(0.8)]
        }
    }
}

// MARK: - Garages Main View (pour simplifier la compilation)
struct GaragesMainView: View {
    @Binding var showingMap: Bool
    @Binding var favoriteGarages: Set<String>
    @ObservedObject var locationService: LocationService
    @ObservedObject var viewModel: GaragesViewModel
    let onToggleFavorite: (Garage) -> Void
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            if showingMap {
                // Vue carte en plein écran
                ModernGaragesMapView(
                    garages: viewModel.garages,
                    favoriteGarages: $favoriteGarages,
                    onToggleFavorite: onToggleFavorite,
                    locationService: locationService
                )
            } else {
                // Vue liste des garages
                garageListView
            }
            
            // Debug temporaire (à retirer en production)
            #if DEBUG
            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🔍 Debug Géolocalisation")
                            .font(.caption)
                            .fontWeight(.bold)
                        
                        Text("Statut: \(locationService.authorizationStatus == .authorizedWhenInUse || locationService.authorizationStatus == .authorizedAlways ? "✅ Autorisé" : "❌ Non autorisé")")
                            .font(.caption2)
                        
                        Text("Mise à jour: \(locationService.isUpdatingLocation ? "🔄 Active" : "⏸️ Arrêtée")")
                            .font(.caption2)
                        
                        if let location = locationService.currentLocation {
                            Text("Position: \(String(format: "%.4f", location.coordinate.latitude)), \(String(format: "%.4f", location.coordinate.longitude))")
                                .font(.caption2)
                            
                            Text("Précision: \(String(format: "%.0f", location.horizontalAccuracy))m")
                                .font(.caption2)
                                .foregroundColor(location.horizontalAccuracy < 50 ? .green : location.horizontalAccuracy < 200 ? .orange : .red)
                        } else {
                            Text("Position: Aucune")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                        
                        if let error = locationService.locationError {
                            Text("Erreur: \(error)")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                        
                        // Boutons de test
                        HStack(spacing: 8) {
                            Button("🔄 Test") {
                                print("🧪 Test d'autorisation basique depuis debug")
                                locationService.requestLocationPermission()
                            }
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                            
                            Button("🚀 Reset") {
                                print("🚀 RESET COMPLET depuis debug")
                                locationService.getCurrentLocation()
                            }
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                        }
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding()
            }
            #endif
        }
    }
    
    // MARK: - Garages List View for GaragesMainView
    private var garageListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // En-tête avec statistiques
                GaragesHeaderView(
                    garageCount: viewModel.garages.count,
                    favoriteCount: favoriteGarages.count
                )
                
                // Liste des garages avec favoris
                ForEach(viewModel.garages) { garage in
                    ModernGarageCard(
                        garage: garage,
                        isFavorite: favoriteGarages.contains(garage.id.uuidString),
                        onToggleFavorite: { _ in onToggleFavorite(garage) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
}

// MARK: - Garages Header View
struct GaragesHeaderView: View {
    let garageCount: Int
    let favoriteCount: Int
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Garages à proximité")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("\(garageCount) garage\(garageCount > 1 ? "s" : "") trouvé\(garageCount > 1 ? "s" : "")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Icône décorative
                Image(systemName: "building.2.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            
            // Statistiques des favoris
            if favoriteCount > 0 {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(favoriteCount) garage\(favoriteCount > 1 ? "s" : "") en favori\(favoriteCount > 1 ? "s" : "")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Modern Garage Card
struct ModernGarageCard: View {
    let garage: Garage
    let isFavorite: Bool
    let onToggleFavorite: (Garage) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header avec nom et favori
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(garage.nom)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(garage.ville)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { onToggleFavorite(garage) }) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundColor(isFavorite ? .yellow : .gray)
                }
            }
            
            // Informations
            VStack(spacing: 12) {
                GarageInfoRow(icon: "location.fill", title: "Adresse", value: garage.adresse, color: .blue)
                GarageInfoRow(icon: "phone.fill", title: "Téléphone", value: garage.telephone, color: .green)
                GarageInfoRow(icon: "clock.fill", title: "Horaires", value: garage.horaires, color: .orange)
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Modern Garages Map View
struct ModernGaragesMapView: View {
    let garages: [Garage]
    @Binding var favoriteGarages: Set<String>
    let onToggleFavorite: (Garage) -> Void
    @ObservedObject var locationService: LocationService
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedGarage: Garage? = nil
    
    private var userLocation: CLLocationCoordinate2D? {
        locationService.currentLocation?.coordinate
    }
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                // Position utilisateur
                if let userLoc = userLocation {
                    Annotation("Ma position", coordinate: userLoc) {
                        ZStack {
                            // Cercle de précision
                            Circle()
                                .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: max(20, min(100, (locationService.currentLocation?.horizontalAccuracy ?? 100) / 5)), 
                                       height: max(20, min(100, (locationService.currentLocation?.horizontalAccuracy ?? 100) / 5)))
                            
                            // Point central précis
                            Circle()
                                .fill(.blue.opacity(0.3))
                                .frame(width: 20, height: 20)
                            Circle()
                                .fill(.blue)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke((locationService.currentLocation?.horizontalAccuracy ?? 100) < 50 ? .green : (locationService.currentLocation?.horizontalAccuracy ?? 100) < 200 ? .orange : .red, lineWidth: 2)
                                        .frame(width: 16, height: 16)
                                )
                        }
                    }
                }
                
                // Marqueurs garages
                ForEach(garages) { garage in
                    Annotation(
                        garage.nom,
                        coordinate: CLLocationCoordinate2D(latitude: garage.latitude, longitude: garage.longitude)
                    ) {
                        GarageMapPin(
                            garage: garage,
                            isFavorite: favoriteGarages.contains(garage.id.uuidString)
                        )
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .onAppear {
                centerOnUserLocation()
            }
            .onReceive(locationService.$currentLocation) { newLocation in
                if newLocation != nil && userLocation == nil {
                    centerOnUserLocation()
                }
            }
        }
    }
    
    private func centerOnUserLocation() {
        if let userLoc = userLocation {
            withAnimation(.easeInOut(duration: 1.0)) {
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: userLoc,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
        }
    }
}

// MARK: - Garage Map Pin
struct GarageMapPin: View {
    let garage: Garage
    let isFavorite: Bool
    
    var body: some View {
        ZStack {
            // Pin principal
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundColor(.blue)
                .background(
                    Circle()
                        .fill(.white)
                        .frame(width: 32, height: 32)
                )
                .shadow(radius: 3)
            
            // Étoile pour les favoris
            if isFavorite {
                VStack {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .background(
                            Circle()
                                .fill(.white)
                                .frame(width: 16, height: 16)
                        )
                        .offset(x: 12, y: -12)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Garage Info Row
struct GarageInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    GaragesView()
} 
