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
                        .accessibilityLabel(garage.isFavorite ? L(CommonTranslations.removeFromFavorites) : L(CommonTranslations.addToFavorites))
                }
            }
            // Adresse et ville
            Text(garage.adresse)
            Text(garage.ville)
            // Téléphone
            Text("\(L(CommonTranslations.phone)) \(garage.telephone)")
            // Services
            Text("\(L(CommonTranslations.services)) \(garage.services.joined(separator: ", "))")
            // Horaires
            Text("\(L(CommonTranslations.hours)) \(garage.horaires)")
            // Bouton appel
            Button(action: callGarage) {
                Label(L(CommonTranslations.call), systemImage: "phone.fill")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            // Bouton itinéraire
            Button(action: openInMaps) {
                Label(L(CommonTranslations.directions), systemImage: "map")
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