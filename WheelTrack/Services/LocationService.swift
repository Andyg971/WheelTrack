import Foundation
import CoreLocation
import SwiftUI

/// Service de géolocalisation simple et efficace comme l'app Maps
class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let locationManager = CLLocationManager()
    
    // États observables
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isUpdatingLocation = false
    @Published var locationError: String?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Configuration
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Se met à jour tous les 10 mètres
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - Méthodes publiques simples
    
    /// Demande l'autorisation comme dans Maps
    func requestLocationPermission() {
        print("🔐 Demande d'autorisation de géolocalisation - Statut actuel: \(authorizationStatus)")
        
        switch authorizationStatus {
        case .notDetermined:
            print("📍 Première demande d'autorisation")
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("❌ Autorisation refusée - Redirection vers les réglages")
            locationError = "Allez dans Réglages > Confidentialité et sécurité > Localisation > WheelTrack pour autoriser l'accès"
            openLocationSettings()
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ Déjà autorisé - Démarrage de la géolocalisation")
            getCurrentLocation()
        @unknown default:
            print("❓ Statut inconnu")
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    /// Obtient la position actuelle (comme le bouton "Ma position" dans Maps)
    func getCurrentLocation() {
        print("📍 getCurrentLocation appelé - Statut: \(authorizationStatus)")
        
        guard isLocationAuthorized else {
            print("❌ Pas d'autorisation - Demande d'autorisation")
            requestLocationPermission()
            return
        }
        
        print("✅ Autorisation OK - Démarrage de la géolocalisation")
        isUpdatingLocation = true
        locationError = nil
        
        // Demande une position ponctuelle précise
        locationManager.requestLocation()
        
        // Timeout de sécurité
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.isUpdatingLocation {
                self.isUpdatingLocation = false
                self.locationError = "Délai d'attente dépassé - Réessayez"
                print("⏰ Timeout de géolocalisation")
            }
        }
    }
    
    /// Commence le suivi continu de la position (pour navigation)
    func startLocationUpdates() {
        guard isLocationAuthorized else {
            requestLocationPermission()
            return
        }
        
        isUpdatingLocation = true
        locationManager.startUpdatingLocation()
    }
    
    /// Arrête le suivi de la position
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        isUpdatingLocation = false
    }
    
    /// Ouvre les réglages pour activer la géolocalisation
    private func openLocationSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    // MARK: - Propriétés calculées
    
    var isLocationAuthorized: Bool {
        return authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }
    
    var locationStatusMessage: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Géolocalisation non configurée"
        case .denied:
            return "Géolocalisation refusée"
        case .restricted:
            return "Géolocalisation restreinte"
        case .authorizedWhenInUse:
            return "Géolocalisation active"
        case .authorizedAlways:
            return "Géolocalisation toujours active"
        @unknown default:
            return "Statut inconnu"
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { 
            print("❌ Aucune localisation dans le tableau")
            return 
        }
        
        print("📍 Position reçue: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        print("🎯 Précision: \(location.horizontalAccuracy)m, Age: \(abs(location.timestamp.timeIntervalSinceNow))s")
        
        // Filtre les positions trop anciennes ou imprécises
        guard location.timestamp.timeIntervalSinceNow > -5.0,
              location.horizontalAccuracy < 100 else { 
            print("⚠️ Position rejetée - Trop ancienne ou imprécise")
            return 
        }
        
        print("✅ Position acceptée et mise à jour")
        
        DispatchQueue.main.async {
            self.currentLocation = location
            self.isUpdatingLocation = false
            self.locationError = nil
        }
        
        // Arrête automatiquement si on demandait juste une position
        if !isUpdatingLocation {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isUpdatingLocation = false
            
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    self.locationError = "Accès à la localisation refusé"
                case .locationUnknown:
                    self.locationError = "Position introuvable"
                case .network:
                    self.locationError = "Erreur réseau"
                default:
                    self.locationError = "Erreur de géolocalisation"
                }
            } else {
                self.locationError = error.localizedDescription
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            
            // Auto-démarrage si l'autorisation est accordée
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.getCurrentLocation()
            }
        }
    }
}

// MARK: - Fonctions utilitaires

extension LocationService {
    
    /// Calcule la distance entre deux points
    func distance(from location1: CLLocation, to location2: CLLocation) -> CLLocationDistance {
        return location1.distance(from: location2)
    }
    
    /// Formate une distance pour l'affichage
    func formatDistance(_ distance: CLLocationDistance) -> String {
        if distance < 1000 {
            return String(format: "%.0f m", distance)
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    /// Obtient les coordonnées sous forme de texte
    var coordinatesText: String {
        guard let location = currentLocation else { return "Position inconnue" }
        return String(format: "%.6f, %.6f", location.coordinate.latitude, location.coordinate.longitude)
    }
}

// MARK: - Vue SwiftUI pour la géolocalisation

struct LocationButton: View {
    @StateObject private var locationService = LocationService.shared
    let onLocationReceived: (CLLocation) -> Void
    
    var body: some View {
        Button(action: {
            locationService.getCurrentLocation()
        }) {
            HStack(spacing: 8) {
                if locationService.isUpdatingLocation {
                    ProgressView()
                        .scaleEffect(0.8)
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: "location.fill")
                        .font(.headline)
                }
                
                Text(locationService.isUpdatingLocation ? "Recherche..." : "Ma position")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    colors: [.blue, .blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(Capsule())
            .disabled(locationService.isUpdatingLocation)
        }
        .onChange(of: locationService.currentLocation) { _, newValue in
            if let location = newValue {
                onLocationReceived(location)
            }
        }
    }
} 