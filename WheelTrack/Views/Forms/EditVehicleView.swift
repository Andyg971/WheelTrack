import SwiftUI

struct EditVehicleView: View {
    var vehicle: Vehicle
    var onSave: (Vehicle) -> Void

    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_language") private var appLanguage = "fr"
    
    // Fonction de localisation
    static func localText(_ key: String, language: String) -> String {
        switch key {
        case "brand":
            return language == "en" ? "Brand" : "Marque"
        case "model":
            return language == "en" ? "Model" : "Modèle"
        case "year":
            return language == "en" ? "Year" : "Année"
        case "license_plate":
            return language == "en" ? "License Plate" : "Immatriculation"
        case "mileage":
            return language == "en" ? "Mileage" : "Kilométrage"
        case "fuel":
            return language == "en" ? "Fuel" : "Carburant"
        case "transmission":
            return language == "en" ? "Transmission" : "Transmission"
        case "color":
            return language == "en" ? "Color" : "Couleur"
        case "purchase_date":
            return language == "en" ? "Purchase Date" : "Date d'achat"
        case "purchase_price":
            return language == "en" ? "Purchase Price" : "Prix d'achat"
        case "purchase_mileage":
            return language == "en" ? "Purchase Mileage" : "Kilométrage à l'achat"
        case "active_vehicle":
            return language == "en" ? "Active Vehicle" : "Véhicule actif"
        case "inactive_note":
            return language == "en" ? "An inactive vehicle will not appear in statistics and will be marked with a gray dot" : "Un véhicule inactif n'apparaîtra pas dans les statistiques et sera marqué d'un point gris"
        case "edit_vehicle":
            return language == "en" ? "Edit Vehicle" : "Modifier véhicule"
        case "save":
            return language == "en" ? "Save" : "Enregistrer"
        case "cancel":
            return language == "en" ? "Cancel" : "Annuler"
        default:
            return key
        }
    }

    @State private var brand: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var licensePlate: String = ""
    @State private var mileage: String = ""
    @State private var fuelType: FuelType = .gasoline
    @State private var transmission: TransmissionType = .manual
    @State private var color: String = ""
    @State private var purchaseDate: Date = Date()
    @State private var purchasePrice: String = ""
    @State private var purchaseMileage: String = ""
    @State private var isActive: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                TextField(EditVehicleView.localText("brand", language: appLanguage), text: $brand)
                TextField(EditVehicleView.localText("model", language: appLanguage), text: $model)
                TextField(EditVehicleView.localText("year", language: appLanguage), text: $year)
                    .keyboardType(.numberPad)
                LicensePlateTextField(EditVehicleView.localText("license_plate", language: appLanguage), text: $licensePlate)
                TextField(EditVehicleView.localText("mileage", language: appLanguage), text: $mileage)
                    .keyboardType(.numberPad)
                Picker(EditVehicleView.localText("fuel", language: appLanguage), selection: $fuelType) {
                    ForEach(FuelType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                Picker(EditVehicleView.localText("transmission", language: appLanguage), selection: $transmission) {
                    ForEach(TransmissionType.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                TextField(EditVehicleView.localText("color", language: appLanguage), text: $color)
                DatePicker(EditVehicleView.localText("purchase_date", language: appLanguage), selection: $purchaseDate, displayedComponents: .date)
                TextField(EditVehicleView.localText("purchase_price", language: appLanguage), text: $purchasePrice)
                    .keyboardType(.decimalPad)
                TextField(EditVehicleView.localText("purchase_mileage", language: appLanguage), text: $purchaseMileage)
                    .keyboardType(.numberPad)
                
                Section {
                    Toggle(EditVehicleView.localText("active_vehicle", language: appLanguage), isOn: $isActive)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                } footer: {
                    Text(EditVehicleView.localText("inactive_note", language: appLanguage))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(EditVehicleView.localText("edit_vehicle", language: appLanguage))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(EditVehicleView.localText("save", language: appLanguage)) {
                        guard let yearInt = Int(year),
                              let mileageDouble = Double(mileage),
                              let purchasePriceDouble = Double(purchasePrice),
                              let purchaseMileageDouble = Double(purchaseMileage)
                        else { return }
                        var updatedVehicle = Vehicle(
                            id: vehicle.id,
                            brand: brand,
                            model: model,
                            year: yearInt,
                            licensePlate: licensePlate,
                            mileage: mileageDouble,
                            fuelType: fuelType,
                            transmission: transmission,
                            color: color,
                            purchaseDate: purchaseDate,
                            purchasePrice: purchasePriceDouble,
                            purchaseMileage: purchaseMileageDouble
                        )
                        
                        // Préserver les autres propriétés du véhicule original
                        updatedVehicle.isActive = isActive
                        updatedVehicle.isAvailableForRent = vehicle.isAvailableForRent
                        updatedVehicle.rentalPrice = vehicle.rentalPrice
                        updatedVehicle.depositAmount = vehicle.depositAmount
                        updatedVehicle.minimumRentalDays = vehicle.minimumRentalDays
                        updatedVehicle.maximumRentalDays = vehicle.maximumRentalDays
                        updatedVehicle.vehicleDescription = vehicle.vehicleDescription
                        updatedVehicle.privateNotes = vehicle.privateNotes
                        updatedVehicle.lastMaintenanceDate = vehicle.lastMaintenanceDate
                        updatedVehicle.nextMaintenanceDate = vehicle.nextMaintenanceDate
                        updatedVehicle.estimatedValue = vehicle.estimatedValue
                        updatedVehicle.resaleDate = vehicle.resaleDate
                        updatedVehicle.resalePrice = vehicle.resalePrice
                        onSave(updatedVehicle)
                        dismiss()
                    }
                    .disabled(brand.isEmpty || model.isEmpty || year.isEmpty || licensePlate.isEmpty || mileage.isEmpty || color.isEmpty || purchasePrice.isEmpty || purchaseMileage.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(EditVehicleView.localText("cancel", language: appLanguage)) { dismiss() }
                }
            }
            .onAppear {
                brand = vehicle.brand
                model = vehicle.model
                year = String(vehicle.year)
                licensePlate = vehicle.licensePlate
                mileage = String(vehicle.mileage)
                fuelType = vehicle.fuelType
                transmission = vehicle.transmission
                color = vehicle.color
                purchaseDate = vehicle.purchaseDate
                purchasePrice = String(vehicle.purchasePrice)
                purchaseMileage = String(vehicle.purchaseMileage)
                isActive = vehicle.isActive
            }
        }
    }
}

#Preview {
    EditVehicleView(vehicle: Vehicle(brand: "Toyota", model: "Corolla", year: 2020, licensePlate: "AB-123-CD", mileage: 50000, fuelType: .diesel, transmission: .manual, color: "Gris", purchaseDate: Date(), purchasePrice: 18000, purchaseMileage: 0)) { _ in }
} 