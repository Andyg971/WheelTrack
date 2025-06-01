import SwiftUI

struct AddVehicleView: View {
    var onAdd: (Vehicle) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var brand = ""
    @State private var model = ""
    @State private var year = ""
    @State private var mileage = ""
    @State private var fuelType: FuelType = .diesel
    @State private var purchasePrice = ""
    @State private var purchaseDate = Date()
    @State private var notes = ""
    @State private var licensePlate = ""
    @State private var transmission: TransmissionType = .manual
    @State private var color = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Marque", text: $brand)
                    TextField("Modèle", text: $model)
                    TextField("Année", text: $year)
                        .keyboardType(.numberPad)
                    TextField("Kilométrage", text: $mileage)
                        .keyboardType(.numberPad)
                    TextField("Plaque d'immatriculation", text: $licensePlate)
                    
                    Picker("Type de carburant", selection: $fuelType) {
                        ForEach(FuelType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker("Transmission", selection: $transmission) {
                        ForEach(TransmissionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Couleur", text: $color)
                } header: {
                    Text("Informations générales")
                }
                
                Section {
                    TextField("Prix d'achat", text: $purchasePrice)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date d'achat", selection: $purchaseDate, displayedComponents: .date)
                } header: {
                    Text("Achat")
                }
                
                Section {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle("Nouveau véhicule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sauvegarder") {
                        saveVehicle()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveVehicle() {
        guard let yearInt = Int(year),
              let mileageDouble = Double(mileage),
              let purchasePriceDouble = Double(purchasePrice) else {
            return
        }
        let vehicle = Vehicle(
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
            purchaseMileage: mileageDouble
        )
        onAdd(vehicle)
        dismiss()
    }
}

#Preview {
    AddVehicleView { _ in }
} 