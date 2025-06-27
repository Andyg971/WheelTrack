import SwiftUI

struct AddMaintenanceView: View {
    let vehicles: [Vehicle]
    var onAdd: (Maintenance) -> Void
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_language") private var appLanguage = "fr"
    
    // Fonction de localisation
    static func localText(_ key: String, language: String) -> String {
        switch key {
        case "new_maintenance":
            return language == "en" ? "New Maintenance" : "Nouvelle maintenance"
        case "general_info":
            return language == "en" ? "General Information" : "Informations générales"
        case "title":
            return language == "en" ? "Title" : "Titre"
        case "date":
            return language == "en" ? "Date" : "Date"
        case "cost":
            return language == "en" ? "Cost" : "Coût"
        case "mileage":
            return language == "en" ? "Mileage" : "Kilométrage"
        case "description":
            return language == "en" ? "Description" : "Description"
        case "garage":
            return language == "en" ? "Garage" : "Garage"
        case "vehicle":
            return language == "en" ? "Vehicle" : "Véhicule"
        case "add":
            return language == "en" ? "Add" : "Ajouter"
        case "cancel":
            return language == "en" ? "Cancel" : "Annuler"
        default:
            return key
        }
    }
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
                Section(AddMaintenanceView.localText("general_info", language: appLanguage)) {
                    TextField(AddMaintenanceView.localText("title", language: appLanguage), text: $titre)
                    DatePicker(AddMaintenanceView.localText("date", language: appLanguage), selection: $date, displayedComponents: .date)
                .environment(\.locale, Locale(identifier: appLanguage == "fr" ? "fr_FR" : "en_US"))
                    TextField(AddMaintenanceView.localText("cost", language: appLanguage), text: $cout)
                        .keyboardType(.decimalPad)
                    TextField(AddMaintenanceView.localText("mileage", language: appLanguage), text: $kilometrage)
                        .keyboardType(.numberPad)
                    TextField(AddMaintenanceView.localText("description", language: appLanguage), text: $description)
                    TextField(AddMaintenanceView.localText("garage", language: appLanguage), text: $garage)
                    
                    Picker(AddMaintenanceView.localText("vehicle", language: appLanguage), selection: $selectedVehicleId) {
                        ForEach(vehicles) { vehicle in
                            Text("\(vehicle.brand) \(vehicle.model) - \(vehicle.licensePlate)").tag(vehicle.id as UUID?)
                        }
                    }
                }
            }
            .navigationTitle(AddMaintenanceView.localText("new_maintenance", language: appLanguage))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(AddMaintenanceView.localText("add", language: appLanguage)) {
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
                    Button(AddMaintenanceView.localText("cancel", language: appLanguage)) { dismiss() }
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