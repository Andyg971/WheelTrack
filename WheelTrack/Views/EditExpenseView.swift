import SwiftUI

public struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: ExpenseCategory
    @State private var description: String
    @State private var amount: String
    @State private var date: Date
    @State private var selectedVehicleId: UUID?
    let expenseId: UUID
    let vehicles: [Vehicle]
    var onSave: (Expense) -> Void
    
    public init(expense: Expense, vehicles: [Vehicle], onSave: @escaping (Expense) -> Void) {
        self._selectedCategory = State(initialValue: expense.category)
        self._description = State(initialValue: expense.description)
        self._amount = State(initialValue: String(expense.amount))
        self._date = State(initialValue: expense.date)
        self._selectedVehicleId = State(initialValue: expense.vehicleId)
        self.expenseId = expense.id
        self.vehicles = vehicles
        self.onSave = onSave
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Picker("Véhicule", selection: $selectedVehicleId) {
                    ForEach(vehicles) { vehicle in
                        Text("\(vehicle.brand) \(vehicle.model) - \(vehicle.licensePlate)")
                            .tag(vehicle.id as UUID?)
                    }
                }
                Picker("Catégorie", selection: $selectedCategory) {
                    ForEach(ExpenseCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                TextField("Description", text: $description)
                TextField("Montant", text: $amount)
                    .keyboardType(.decimalPad)
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }
            .navigationTitle("Modifier la dépense")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        guard let amountValue = Double(amount), !description.isEmpty, let vehicleId = selectedVehicleId else { return }
                        let updatedExpense = Expense(
                            id: expenseId,
                            vehicleId: vehicleId,
                            date: date,
                            amount: amountValue,
                            category: selectedCategory,
                            description: description,
                            mileage: 0, // valeur par défaut
                            receiptImageURL: nil, // valeur par défaut
                            notes: "" // valeur par défaut
                        )
                        onSave(updatedExpense)
                        dismiss()
                    }) {
                        Text("Enregistrer")
                    }
                    .disabled(description.isEmpty || Double(amount) == nil || selectedVehicleId == nil)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Annuler")
                    }
                }
            }
        }
    }
}

#Preview {
    EditExpenseView(
        expense: Expense(id: UUID(), vehicleId: UUID(), date: Date(), amount: 42.0, category: .fuel, description: "Test"),
        vehicles: [Vehicle(brand: "Toyota", model: "Corolla", year: 2020, licensePlate: "AB-123-CD", mileage: 50000, fuelType: .diesel, transmission: .manual, color: "Gris", purchaseDate: Date(), purchasePrice: 18000, purchaseMileage: 0)]
    ) { _ in }
} 
