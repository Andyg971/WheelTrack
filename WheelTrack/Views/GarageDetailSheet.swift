import SwiftUI
import MapKit
import UIKit

struct GarageDetailSheet: View {
    @ObservedObject var viewModel: GaragesViewModel
    let garage: Garage

    var body: some View {
        VStack(spacing: 16) {
            // Titre et favori
            HStack {
                Text(garage.nom)
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: {
                    viewModel.toggleFavorite(garage)
                }) {
                    Image(systemName: garage.isFavorite ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .accessibilityLabel(garage.isFavorite ? "Retirer des favoris" : "Ajouter aux favoris")
                }
            }
            // Adresse et ville
            Text(garage.adresse)
            Text(garage.ville)
            // Téléphone
            Text("Téléphone : \(garage.telephone)")
            // Services
            Text("Services : \(garage.services.joined(separator: ", "))")
            // Horaires
            Text("Horaires : \(garage.horaires)")
            // Bouton appel
            Button(action: callGarage) {
                Label("Appeler", systemImage: "phone.fill")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            // Bouton itinéraire
            Button(action: openInMaps) {
                Label("Itinéraire dans Plans", systemImage: "map")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            Spacer()
        }
        .padding()
    }

    /// Lance l'appel téléphonique vers le garage
    func callGarage() {
        let tel = "tel://" + garage.telephone.filter("0123456789".contains)
        guard let url = URL(string: tel) else { return }
        
        #if os(iOS)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        #endif
    }

    /// Ouvre l'itinéraire dans Plans
    func openInMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: garage.latitude, longitude: garage.longitude)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = garage.nom
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
} 