import SwiftUI

struct GarageFormView: View {
    var garage: Garage? = nil
    var onSave: (Garage) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var nom: String = ""
    @State private var adresse: String = ""
    @State private var ville: String = ""
    @State private var telephone: String = ""
    @State private var services: String = ""
    @State private var horaires: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nom", text: $nom)
                TextField("Adresse", text: $adresse)
                TextField("Ville", text: $ville)
                TextField("Téléphone", text: $telephone)
                TextField("Services (séparés par ,)", text: $services)
                TextField("Horaires", text: $horaires)
                TextField("Latitude", text: $latitude)
                    .keyboardType(.decimalPad)
                TextField("Longitude", text: $longitude)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle(garage == nil ? "Nouveau garage" : "Modifier garage")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        guard let lat = Double(latitude), let lon = Double(longitude) else { return }
                        let newGarage = Garage(
                            id: garage?.id ?? UUID(),
                            nom: nom,
                            adresse: adresse,
                            ville: ville,
                            telephone: telephone,
                            services: services.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                            horaires: horaires,
                            latitude: lat,
                            longitude: lon,
                            isFavorite: garage?.isFavorite ?? false
                        )
                        onSave(newGarage)
                        dismiss()
                    }
                    .disabled(nom.isEmpty || adresse.isEmpty || ville.isEmpty || latitude.isEmpty || longitude.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
            .onAppear {
                if let garage = garage {
                    nom = garage.nom
                    adresse = garage.adresse
                    ville = garage.ville
                    telephone = garage.telephone
                    services = garage.services.joined(separator: ", ")
                    horaires = garage.horaires
                    latitude = String(garage.latitude)
                    longitude = String(garage.longitude)
                }
            }
        }
    }
}

#Preview {
    GarageFormView { _ in }
} 