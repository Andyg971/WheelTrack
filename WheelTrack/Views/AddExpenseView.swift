import SwiftUI

struct AddExpenseView: View {
    // Liste des véhicules disponibles
    let vehicles: [Vehicle]
    // Closure appelée à la validation
    var onAdd: (Expense) -> Void
    // Champs du formulaire
    @State private var selectedCategory: ExpenseCategory = .fuel
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var date: Date = Date()
    @State private var selectedVehicleId: UUID?
    
    // Pour fermer la vue
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informations générales") {
                    Picker("Véhicule", selection: $selectedVehicleId) {
                        ForEach(vehicles) { vehicle in
                            Text("\(vehicle.brand) \(vehicle.model) - \(vehicle.licensePlate)")
                                .tag(vehicle.id as UUID?)
                        }
                    }
                    .accessibilityIdentifier("vehiclePicker")
                    
                    Picker("Catégorie", selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .accessibilityIdentifier("categoryPicker")
                    
                    TextField("Description", text: $description)
                        .accessibilityIdentifier("descriptionField")
                    
                    TextField("Montant", text: $amount)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("amountField")
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .accessibilityIdentifier("datePicker")
                }
            }
            .navigationTitle(NSLocalizedString("Nouvelle dépense", comment: "Titre du formulaire d'ajout de dépense"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("Ajouter", comment: "Bouton pour ajouter une dépense")) {
                        guard let amountValue = Double(amount), !description.isEmpty, let vehicleId = selectedVehicleId else { return }
                        
                        let expense = Expense(
                            id: UUID(),
                            vehicleId: vehicleId,
                            date: date,
                            amount: amountValue,
                            category: selectedCategory,
                            description: description,
                            mileage: 0,
                            receiptImageURL: nil,
                            notes: ""
                        )
                        onAdd(expense)
                        dismiss()
                    }
                    .disabled(description.isEmpty || Double(amount) == nil || selectedVehicleId == nil)
                    .accessibilityIdentifier("addButton")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Annuler", comment: "Bouton pour annuler l'ajout")) { dismiss() }
                        .accessibilityIdentifier("cancelButton")
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

// Explications pédagogiques :
// - L'utilisateur choisit le véhicule associé à la dépense.
// - Les identifiants d'accessibilité facilitent les tests et l'accessibilité.
// - Les textes sont localisés avec NSLocalizedString.

#Preview {
    AddExpenseView(vehicles: [
        Vehicle(brand: "Toyota", model: "Corolla", year: 2020, licensePlate: "AB-123-CD", mileage: 50000, fuelType: .diesel, transmission: .manual, color: "Gris", purchaseDate: Date(), purchasePrice: 18000, purchaseMileage: 0)
    ]) { expense in
        print(expense)
    }
} 