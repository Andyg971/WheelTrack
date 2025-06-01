import SwiftUI
import MapKit

/// Vue affichant les maintenances sur une carte, associées à leur garage.
struct MaintenanceMapView: View {
    let maintenances: [Maintenance]
    let garages: [Garage]
    var onSelectMaintenance: ((Maintenance, Garage) -> Void)? = nil
    @State private var region: MKCoordinateRegion

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
        Map(position: $region) {
            ForEach(maintenancesWithGarage) { item in
                Annotation(
                    "\(item.maintenance.titre)",
                    coordinate: item.coordinate
                ) {
                    Button(action: {
                        onSelectMaintenance?(item.maintenance, item.garage)
                    }) {
                        VStack {
                            Image(systemName: "wrench.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            Text(item.maintenance.titre)
                                .font(.caption)
                            Text(item.garage.nom)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .accessibilityIdentifier("MaintenanceMapView")
    }

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

/// Preview pour développement rapide
#Preview {
    // Exemple de données fictives pour la prévisualisation
    let garages = [
        Garage(
            id: UUID(),
            nom: "Garage Renault",
            adresse: "1 rue de Paris",
            ville: "Paris",
            telephone: "0102030405",
            services: ["Vidange", "Diagnostic"],
            horaires: "Lun-Ven: 8h-19h\nSam: 9h-17h",
            latitude: 48.8566,
            longitude: 2.3522,
            isFavorite: false
        )
    ]
    let maintenances = [
        Maintenance(id: UUID(), titre: "Vidange", date: Date(), cout: 100, kilometrage: 50000, description: "Vidange complète", garage: "Garage Renault", vehicule: "Toyota Corolla")
    ]
    MaintenanceMapView(maintenances: maintenances, garages: garages)
} 