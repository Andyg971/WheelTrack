import SwiftUI
import MapKit

/// Vue affichant les maintenances sur une carte, associées à leur garage.
/// Inclut la localisation de l'utilisateur et calcul des distances.
struct MaintenanceMapView: View {
    let maintenances: [Maintenance]
    let garages: [Garage]
    var onSelectMaintenance: ((Maintenance, Garage) -> Void)? = nil
    
    // MARK: - État de la vue
    @State private var region: MKCoordinateRegion
    @StateObject private var locationService = LocationService.shared
    @State private var showingLocationError = false
    @State private var selectedGarage: Garage? = nil
    @State private var showingGarageDetail = false
    @State private var favoriteGarages: Set<String> = [] // Système de favoris local

    /// Initialisation avec centrage sur le premier garage ou Paris par défaut.
    init(maintenances: [Maintenance], garages: [Garage], onSelectMaintenance: ((Maintenance, Garage) -> Void)? = nil) {
        self.maintenances = maintenances
        self.garages = garages
        self.onSelectMaintenance = onSelectMaintenance
        if let firstGarage = garages.first {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: firstGarage.latitude, longitude: firstGarage.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        } else {
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522), // Paris
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }
    }

    var body: some View {
        ZStack {
            // MARK: - Carte principale
            Map(position: .constant(MapCameraPosition.region(region))) {
                
                // MARK: - Position de l'utilisateur
                if let userLocation = locationService.currentLocation {
                    Annotation("Ma position", coordinate: userLocation.coordinate) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 20, height: 20)
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                
                // MARK: - Épingles des maintenances
                ForEach(maintenancesWithGarage) { item in
                    Annotation(
                        "\(item.maintenance.titre)",
                        coordinate: item.coordinate
                    ) {
                        Button(action: {
                            onSelectMaintenance?(item.maintenance, item.garage)
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: "wrench.fill")
                                    .foregroundColor(.orange)
                                    .font(.title2)
                                Text(item.maintenance.titre)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text(item.garage.nom)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                // Affichage de la distance si disponible
                                if let userLocation = locationService.currentLocation {
                                    Text(formattedDistance(to: item.garage, from: userLocation))
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 4)
                        }
                        .onLongPressGesture {
                            // Appui long pour voir les détails du garage
                            selectedGarage = item.garage
                            showingGarageDetail = true
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // MARK: - Boutons de contrôle
            VStack {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // Bouton de localisation
                        Button(action: {
                            if locationService.currentLocation != nil {
                                centerOnUserLocation()
                            } else {
                                print("🔄 Demande de localisation depuis MaintenanceMapView")
                                locationService.requestLocationPermission()
                            }
                        }) {
                            Image(systemName: locationService.isUpdatingLocation ? "location.fill.viewfinder" : "location")
                                .font(.title2)
                                .foregroundColor(locationService.currentLocation != nil ? .blue : .gray)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                        
                        // Bouton pour centrer sur les garages
                        Button(action: {
                            centerOnGarages()
                        }) {
                            Image(systemName: "map")
                                .font(.title2)
                                .foregroundColor(.gray)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.trailing)
                }
                Spacer()
            }
            .padding(.top)
            
            // MARK: - Indicateur de chargement
            if locationService.isUpdatingLocation {
                VStack {
                    Spacer()
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text(L(CommonTranslations.locatingInProgress))
                            .font(.caption)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.bottom)
                }
            }
        }
        .onAppear {
            // Demander automatiquement la localisation au démarrage
            print("🚀 MaintenanceMapView appeared - requesting location permission")
            locationService.requestLocationPermission()
        }
        .alert("Erreur de localisation", isPresented: $showingLocationError) {
            Button("OK") { }
            Button("Réglages") {
                openSettings()
            }
        } message: {
            Text(locationService.locationError ?? "Une erreur est survenue")
        }
        .onChange(of: locationService.locationError) { _, errorMessage in
            showingLocationError = errorMessage != nil
        }
        .accessibilityIdentifier("MaintenanceMapView")
        .sheet(isPresented: $showingGarageDetail) {
            if let garage = selectedGarage {
                MaintenanceGarageDetailView(
                    garage: garage,
                    isFavorite: favoriteGarages.contains(garage.id.uuidString),
                    onToggleFavorite: toggleFavorite
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Méthodes privées
    
    /// Associe chaque maintenance à son garage (si trouvé)
    private var maintenancesWithGarage: [MaintenanceWithGarage] {
        maintenances.compactMap { maintenance in
            if let garage = garages.first(where: { $0.nom == maintenance.garage }) {
                return MaintenanceWithGarage(maintenance: maintenance, garage: garage)
            } else {
                return nil
            }
        }
    }
    
    /// Centre la carte sur la position de l'utilisateur
    private func centerOnUserLocation() {
        guard let userLocation = locationService.currentLocation else { return }
        
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
    
    /// Centre la carte pour voir tous les garages
    private func centerOnGarages() {
        guard !garages.isEmpty else { return }
        
        let coordinates = garages.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
        let mapRect = coordinates.reduce(MKMapRect.null) { rect, coordinate in
            let point = MKMapPoint(coordinate)
            let pointRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
            return rect.union(pointRect)
        }
        
        let expandedRect = mapRect.insetBy(dx: -mapRect.size.width * 0.1, dy: -mapRect.size.height * 0.1)
        
        withAnimation(.easeInOut(duration: 1.0)) {
            region = MKCoordinateRegion(expandedRect)
        }
    }
    
    /// Calcule et formate la distance entre l'utilisateur et un garage
    private func formattedDistance(to garage: Garage, from userLocation: CLLocation) -> String {
        let garageLocation = CLLocation(latitude: garage.latitude, longitude: garage.longitude)
        let distance = locationService.distance(from: userLocation, to: garageLocation)
        return locationService.formatDistance(distance)
    }
    
    /// Ouvre les réglages de l'app
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    /// Gère les favoris localement dans cette vue
    private func toggleFavorite(_ garage: Garage) {
        let garageId = garage.id.uuidString
        
        if favoriteGarages.contains(garageId) {
            favoriteGarages.remove(garageId)
        } else {
            favoriteGarages.insert(garageId)
        }
        
        // Animation de feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    /// Structure pour lier maintenance et garage (avec coordonnées)
    struct MaintenanceWithGarage: Identifiable {
        let maintenance: Maintenance
        let garage: Garage
        var id: UUID { maintenance.id }
        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: garage.latitude, longitude: garage.longitude)
        }
    }
}

/// Vue de détail simplifiée pour les garages dans le contexte des maintenances
struct MaintenanceGarageDetailView: View {
    let garage: Garage
    let isFavorite: Bool
    let onToggleFavorite: (Garage) -> Void
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationService = LocationService.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // En-tête avec nom et actions principales
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(garage.nom)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(L(CommonTranslations.carGarage))
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
                        
                        // Actions rapides
                        HStack(spacing: 16) {
                            QuickActionButtonLocal(
                                icon: "phone.fill",
                                title: L(CommonTranslations.call),
                                color: .green
                            ) {
                                callGarage()
                            }
                            
                            QuickActionButtonLocal(
                                icon: "car.fill",
                                title: L(CommonTranslations.directions),
                                color: .blue
                            ) {
                                openInMaps()
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // Informations de contact
                    VStack(alignment: .leading, spacing: 16) {
                        Text(L(CommonTranslations.informations))
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InfoRowSimple(
                                icon: "location.fill", 
                                title: "Adresse",
                                content: garage.adresse,
                                color: .blue
                            )
                            
                            InfoRowSimple(
                                icon: "phone.fill",
                                title: "Téléphone", 
                                content: garage.telephone,
                                color: .green
                            )
                            
                            // Distance si localisation disponible
                            if let userLocation = locationService.currentLocation {
                                let distance = calculateDistance(to: garage, from: userLocation)
                                InfoRowSimple(
                                    icon: "ruler.fill",
                                    title: "Distance",
                                    content: formatDistance(distance),
                                    color: .purple
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Retour") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func callGarage() {
        let tel = "tel://" + garage.telephone.filter("0123456789".contains)
        guard let url = URL(string: tel) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func openInMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: garage.latitude, longitude: garage.longitude)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = garage.nom
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    private func sendMessage() {
        let sms = "sms:\(garage.telephone)"
        guard let url = URL(string: sms) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareGarage() {
        let text = "🚗 \(garage.nom)\n📍 \(garage.adresse), \(garage.ville)\n📞 \(garage.telephone)"
        let activityController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityController, animated: true)
        }
    }
    
    private func calculateDistance(to garage: Garage, from userLocation: CLLocation) -> CLLocationDistance {
        let garageLocation = CLLocation(latitude: garage.latitude, longitude: garage.longitude)
        return userLocation.distance(from: garageLocation)
    }
    
    private func formatDistance(_ distance: CLLocationDistance) -> String {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter.string(fromDistance: distance)
    }
}

/// Composant simple pour afficher les informations
struct InfoRowSimple: View {
    let icon: String
    let title: String
    let content: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
}

/// Composant d'action rapide local pour MaintenanceMapView
struct QuickActionButtonLocal: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(color)
                    .clipShape(Circle())
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

/// Preview pour développement rapide
#Preview {
    // Exemple de données fictives pour la prévisualisation
    let garages = [
        Garage(
            id: UUID(),
            name: "Garage Renault",
            address: "1 rue de Paris",
            latitude: 48.8566,
            longitude: 2.3522
        )
    ]
    let maintenances = [
        Maintenance(id: UUID(), titre: "Vidange", date: Date(), cout: 100, kilometrage: 50000, description: "Vidange complète", garage: "Garage Renault", vehicule: "Toyota Corolla")
    ]
    MaintenanceMapView(maintenances: maintenances, garages: garages)
} 