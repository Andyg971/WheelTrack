import SwiftUI
import CoreLocation

struct AddGarageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var address = ""
    @State private var city = ""
    @State private var postalCode = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var website = ""
    @State private var openingHours = ""
    @State private var services: Set<String> = []
    @State private var notes = ""
    // Champs pour les coordonnées GPS
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var isGeocoding = false
    @State private var geocodeError: String?
    
    let availableServices = ["Vidange", "Diagnostic", "Carrosserie", "Pneumatiques", "Mécanique générale", "Électricité", "Climatisation", "Pare-brise"]
    
    var body: some View {
        NavigationView {
            Form {
                // Section infos générales
                Section(header: Text("Informations générales")) {
                    TextField("Nom du garage", text: $name)
                    TextField("Adresse", text: $address)
                    HStack {
                        TextField("Code postal", text: $postalCode)
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                        TextField("Ville", text: $city)
                    }
                    TextField("Téléphone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Site web", text: $website)
                        .keyboardType(.URL)
                }
                // Section coordonnées GPS
                Section(header: Text("Coordonnées GPS")) {
                    HStack {
                        TextField("Latitude", text: $latitude)
                            .keyboardType(.decimalPad)
                        TextField("Longitude", text: $longitude)
                            .keyboardType(.decimalPad)
                    }
                    Button("Trouver coordonnées") {
                        isGeocoding = true
                        geocodeError = nil
                        let fullAddress = "\(address), \(postalCode) \(city)"
                        GeocodingService.shared.geocode(address: fullAddress) { coordinate in
                            isGeocoding = false
                            if let coordinate = coordinate {
                                latitude = "\(coordinate.latitude)"
                                longitude = "\(coordinate.longitude)"
                            } else {
                                geocodeError = "Adresse introuvable. Vérifie l'adresse et la ville."
                            }
                        }
                    }
                    .disabled(isGeocoding || address.isEmpty || city.isEmpty)
                    if let error = geocodeError {
                        Text(error).foregroundColor(.red)
                    }
                }
                // Section horaires
                Section(header: Text("Horaires d'ouverture")) {
                    TextEditor(text: $openingHours)
                        .frame(height: 100)
                }
                // Section services
                Section(header: Text("Services proposés")) {
                    ForEach(availableServices, id: \.self) { service in
                        Toggle(service, isOn: Binding(
                            get: { services.contains(service) },
                            set: { isSelected in
                                if isSelected {
                                    services.insert(service)
                                } else {
                                    services.remove(service)
                                }
                            }
                        ))
                    }
                }
                // Section notes
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Nouveau garage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        // Préparer le garage avec toutes les infos (y compris coordonnées)
                        // TODO: Enregistrer dans la base ou ViewModel
                        dismiss()
                    }
                    .disabled(name.isEmpty || address.isEmpty || city.isEmpty || postalCode.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddGarageView()
} 