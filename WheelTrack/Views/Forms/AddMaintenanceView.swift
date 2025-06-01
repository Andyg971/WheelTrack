import SwiftUI

struct AddMaintenanceView: View {
    let vehicles: [Vehicle]
    var onAdd: (Maintenance) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var titre: String = ""
    @State private var date: Date = Date()
    @State private var cout: String = ""
    @State private var kilometrage: String = ""
    @State private var description: String = ""
    @State private var garage: String = ""
    @State private var selectedVehicleId: UUID?

    var body: some View {
        NavigationStack {
            Form {
                Section("Informations générales") {
                    TextField("Titre", text: $titre)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Coût", text: $cout)
                        .keyboardType(.decimalPad)
                    TextField("Kilométrage", text: $kilometrage)
                        .keyboardType(.numberPad)
                    TextField("Description", text: $description)
                    TextField("Garage", text: $garage)
                    
                    Picker("Véhicule", selection: $selectedVehicleId) {
                        ForEach(vehicles) { vehicle in
                            Text("\(vehicle.brand) \(vehicle.model) - \(vehicle.licensePlate)").tag(vehicle.id as UUID?)
                        }
                    }
                }
            }
            .navigationTitle("Nouvelle maintenance")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        guard !titre.isEmpty, let coutValue = Double(cout), 
                              let kilometrageValue = Int(kilometrage), 
                              let vehicleId = selectedVehicleId,
                              let vehicle = vehicles.first(where: { $0.id == vehicleId }) else { return }
                        
                        let maintenance = Maintenance(
                            titre: titre,
                            date: date,
                            cout: coutValue,
                            kilometrage: kilometrageValue,
                            description: description,
                            garage: garage,
                            vehicule: "\(vehicle.brand) \(vehicle.model)"
                        )
                        onAdd(maintenance)
                        dismiss()
                    }
                    .disabled(titre.isEmpty || Double(cout) == nil || Int(kilometrage) == nil || selectedVehicleId == nil)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
        .onAppear {
            // Sélectionne le premier véhicule par défaut si disponible
            if selectedVehicleId == nil {
                selectedVehicleId = vehicles.first?.id
            }
        }
    }
}

#Preview {
    AddMaintenanceView(vehicles: []) { _ in }
} 