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
        print("🏗️ LocationService: Initialisation...")
        setupLocationManager()
    }
    
    // MARK: - Configuration
    
    private func setupLocationManager() {
        print("🔧 LocationService: Configuration du CLLocationManager...")
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        
        // Vérification du statut initial sur background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let initialStatus = self.locationManager.authorizationStatus
            let servicesEnabled = CLLocationManager.locationServicesEnabled()
            
            DispatchQueue.main.async {
                print("📊 Statut initial: \(initialStatus.rawValue) (\(self.statusDescription(initialStatus)))")
                print("🌍 Services de localisation activés: \(servicesEnabled)")
                self.authorizationStatus = initialStatus
            }
        }
        
        print("✅ LocationManager configuré avec succès")
    }
    
    // MARK: - Diagnostic
    
    private func statusDescription(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Non déterminé"
        case .denied: return "Refusé"
        case .restricted: return "Restreint"
        case .authorizedWhenInUse: return "Autorisé pendant utilisation"
        case .authorizedAlways: return "Toujours autorisé"
        @unknown default: return "Statut inconnu"
        }
    }
    
    // MARK: - Méthodes publiques
    
    /// Demande l'autorisation avec diagnostic complet
    func requestLocationPermission() {
        print("\n🔐 === DEMANDE D'AUTORISATION DE GÉOLOCALISATION ===")
        print("📱 Thread actuel: \(Thread.isMainThread ? "Main" : "Background")")
        print("📊 Statut actuel: \(authorizationStatus.rawValue) (\(statusDescription(authorizationStatus)))")
        print("📊 Statut CLLocationManager: \(locationManager.authorizationStatus.rawValue)")
        
        // Vérification critique : Services de localisation sur background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let servicesEnabled = CLLocationManager.locationServicesEnabled()
            
            DispatchQueue.main.async {
                print("🌍 Services de localisation: \(servicesEnabled)")
                
                guard servicesEnabled else {
                    print("❌ ERREUR CRITIQUE: Services de localisation désactivés sur l'appareil!")
                    self.locationError = "Services de localisation désactivés. Allez dans Réglages > Confidentialité > Localisation."
                    return
                }
                
                // Synchronisation du statut
                let currentStatus = self.locationManager.authorizationStatus
                if currentStatus != self.authorizationStatus {
                    print("⚠️ Synchronisation du statut: \(self.authorizationStatus.rawValue) → \(currentStatus.rawValue)")
                    self.authorizationStatus = currentStatus
                }
                
                self.handleAuthorizationRequest(for: currentStatus)
            }
        }
    }
    
    /// Gère la demande d'autorisation selon le statut
    private func handleAuthorizationRequest(for status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("🚀 PREMIÈRE DEMANDE - La pop-up VA s'afficher maintenant!")
            print("📱 Appel de requestWhenInUseAuthorization()...")
            
            // APPEL CRITIQUE : Doit être sur le main thread
            locationManager.requestWhenInUseAuthorization()
            print("✅ requestWhenInUseAuthorization() appelé depuis le Main Thread")
            
        case .denied:
            print("❌ AUTORISATION REFUSÉE - Redirection vers réglages")
            self.locationError = "Géolocalisation refusée. Allez dans Réglages > Confidentialité > Localisation > WheelTrack."
            openLocationSettings()
            
        case .restricted:
            print("🚫 AUTORISATION RESTREINTE")
            self.locationError = "L'accès à la localisation est restreint sur cet appareil."
            
        case .authorizedWhenInUse, .authorizedAlways:
            print("✅ DÉJÀ AUTORISÉ - Démarrage géolocalisation")
            getCurrentLocation()
            
        @unknown default:
            print("STATUT INCONNU - Tentative de demande d'autorisation")
            locationManager.requestWhenInUseAuthorization()
        }
        
        print("🔐 === FIN DEMANDE D'AUTORISATION ===\n")
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
        
        // Demande une position avec suivi continu pour que iOS comprenne que l'app utilise activement la géolocalisation
        locationManager.startUpdatingLocation()
        
        // Timeout de sécurité
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if self.isUpdatingLocation {
                self.isUpdatingLocation = false
                self.locationError = "Délai d'attente dépassé - Réessayez"
                self.locationManager.stopUpdatingLocation()
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
            
            // Notifier les autres composants que la localisation a été mise à jour
            NotificationCenter.default.post(name: NSNotification.Name("LocationUpdated"), object: location)
            print("📡 Notification LocationUpdated envoyée")
        }
        
        // Arrête le suivi après avoir reçu une position pour getCurrentLocation
        locationManager.stopUpdatingLocation()
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
        print("\n🔄 === CHANGEMENT D'AUTORISATION DÉTECTÉ ===")
        print("📱 Thread: \(Thread.isMainThread ? "Main" : "Background")")
        print("📊 Nouveau statut: \(status.rawValue) (\(statusDescription(status)))")
        print("📊 Ancien statut: \(authorizationStatus.rawValue) (\(statusDescription(authorizationStatus)))")
        
        // Vérification des services sur background thread
        DispatchQueue.global(qos: .userInitiated).async {
            let servicesEnabled = CLLocationManager.locationServicesEnabled()
            
            DispatchQueue.main.async {
                print("🌍 Services activés: \(servicesEnabled)")
                self.authorizationStatus = status
                
                switch status {
                case .notDetermined:
                    print("Statut: Non déterminé - En attente de décision utilisateur")
                    
                case .denied:
                    print("❌ AUTORISATION REFUSÉE par l'utilisateur")
                    self.isUpdatingLocation = false
                    self.locationError = "Accès à la localisation refusé. Allez dans Réglages > Confidentialité > Localisation > WheelTrack pour autoriser l'accès."
                    
                case .restricted:
                    print("🚫 AUTORISATION RESTREINTE par restrictions parentales")
                    self.isUpdatingLocation = false
                    self.locationError = "L'accès à la localisation est restreint sur cet appareil."
                    
                case .authorizedWhenInUse:
                    print("✅ AUTORISATION ACCORDÉE - Pendant utilisation de l'app")
                    self.locationError = nil
                    print("🚀 Démarrage automatique de la géolocalisation...")
                    self.getCurrentLocation()
                    
                case .authorizedAlways:
                    print("✅ AUTORISATION TOUJOURS ACCORDÉE - En permanence")
                    self.locationError = nil
                    print("🚀 Démarrage automatique de la géolocalisation...")
                    self.getCurrentLocation()
                    
                @unknown default:
                    print("STATUT INCONNU: \(status.rawValue)")
                    self.isUpdatingLocation = false
                    self.locationError = "Statut d'autorisation inconnu"
                }
                
                print("🔄 === FIN CHANGEMENT D'AUTORISATION ===\n")
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