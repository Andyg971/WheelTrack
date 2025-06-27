import SwiftUI

struct EditMaintenanceView: View {
    var maintenance: Maintenance
    var onSave: (Maintenance) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var titre: String = ""
    @State private var date: Date = Date()
    @State private var cout: String = ""
    @State private var kilometrage: String = ""
    @State private var description: String = ""
    @State private var garage: String = ""
    @State private var vehicule: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Titre", text: $titre)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                .environment(\.locale, Locale(identifier: "fr_FR"))
                TextField("Coût", text: $cout)
                    .keyboardType(.decimalPad)
                TextField("Kilométrage", text: $kilometrage)
                    .keyboardType(.numberPad)
                TextField("Description", text: $description)
                TextField("Garage", text: $garage)
                TextField("Véhicule", text: $vehicule)
            }
            .navigationTitle("Modifier maintenance")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        guard let coutDouble = Double(cout), let kmInt = Int(kilometrage) else { return }
                        let updated = Maintenance(
                            id: maintenance.id,
                            titre: titre,
                            date: date,
                            cout: coutDouble,
                            kilometrage: kmInt,
                            description: description,
                            garage: garage,
                            vehicule: vehicule
                        )
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(titre.isEmpty || cout.isEmpty || kilometrage.isEmpty || garage.isEmpty || vehicule.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
            .onAppear {
                titre = maintenance.titre
                date = maintenance.date
                cout = String(maintenance.cout)
                kilometrage = String(maintenance.kilometrage)
                description = maintenance.description
                garage = maintenance.garage
                vehicule = maintenance.vehicule
            }
        }
    }
}

#Preview {
    EditMaintenanceView(maintenance: Maintenance(id: UUID(), titre: "Vidange", date: Date(), cout: 100, kilometrage: 50000, description: "Changement huile", garage: "Garage X", vehicule: "Toyota")) { _ in }
} 