import SwiftUI

struct EditVehicleView: View {
    var vehicle: Vehicle
    var onSave: (Vehicle) -> Void

    @Environment(\.dismiss) private var dismiss

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

    var body: some View {
        NavigationStack {
            Form {
                TextField("Marque", text: $brand)
                TextField("Modèle", text: $model)
                TextField("Année", text: $year)
                    .keyboardType(.numberPad)
                TextField("Immatriculation", text: $licensePlate)
                TextField("Kilométrage", text: $mileage)
                    .keyboardType(.numberPad)
                Picker("Carburant", selection: $fuelType) {
                    ForEach(FuelType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                Picker("Transmission", selection: $transmission) {
                    ForEach(TransmissionType.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                TextField("Couleur", text: $color)
                DatePicker("Date d'achat", selection: $purchaseDate, displayedComponents: .date)
                TextField("Prix d'achat", text: $purchasePrice)
                    .keyboardType(.decimalPad)
                TextField("Kilométrage à l'achat", text: $purchaseMileage)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Modifier véhicule")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        guard let yearInt = Int(year),
                              let mileageDouble = Double(mileage),
                              let purchasePriceDouble = Double(purchasePrice),
                              let purchaseMileageDouble = Double(purchaseMileage)
                        else { return }
                        let updatedVehicle = Vehicle(
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
                        onSave(updatedVehicle)
                        dismiss()
                    }
                    .disabled(brand.isEmpty || model.isEmpty || year.isEmpty || licensePlate.isEmpty || mileage.isEmpty || color.isEmpty || purchasePrice.isEmpty || purchaseMileage.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
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
            }
        }
    }
}

#Preview {
    EditVehicleView(vehicle: Vehicle(brand: "Toyota", model: "Corolla", year: 2020, licensePlate: "AB-123-CD", mileage: 50000, fuelType: .diesel, transmission: .manual, color: "Gris", purchaseDate: Date(), purchasePrice: 18000, purchaseMileage: 0)) { _ in }
} 