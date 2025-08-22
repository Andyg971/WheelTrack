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
    
    // États de validation
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    // Pour fermer la vue
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationService = LocalizationService.shared
    
    var body: some View {
        NavigationStack {
            Form {
                Section(localizationService.text("Informations générales", "General Information")) {
                    Picker(localizationService.text("Véhicule", "Vehicle"), selection: $selectedVehicleId) {
                        ForEach(vehicles) { vehicle in
                            Text("\(vehicle.brand) \(vehicle.model) - \(vehicle.licensePlate)")
                                .tag(vehicle.id as UUID?)
                        }
                    }
                    .accessibilityIdentifier("vehiclePicker")
                    
                    Picker(CommonTranslations.category.0, selection: $selectedCategory) {
                        ForEach(ExpenseCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .accessibilityIdentifier("categoryPicker")
                    
                    TextField(CommonTranslations.description.0, text: $description)
                        .accessibilityIdentifier("descriptionField")
                    
                    TextField(CommonTranslations.amount.0, text: $amount)
                        .keyboardType(.decimalPad)
                        .accessibilityIdentifier("amountField")
                    
                    DatePicker(CommonTranslations.date.0, selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: localizationService.currentLanguage == "fr" ? "fr_FR" : "en_US"))
                        .accessibilityIdentifier("datePicker")
                }
            }
            .navigationTitle(localizationService.text("Nouvelle dépense", "New Expense"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(CommonTranslations.add.0) {
                        if validateForm() {
                            let amountValue = Double(amount)!
                            let vehicleId = selectedVehicleId!
                            
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
                        } else {
                            showingValidationAlert = true
                        }
                    }
                    .accessibilityIdentifier("addButton")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(CommonTranslations.cancel.0) { dismiss() }
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
        .alert(L(CommonTranslations.validationError), isPresented: $showingValidationAlert) {
            Button(L(CommonTranslations.ok)) { }
        } message: {
            Text(validationMessage)
        }
    }
    
    // MARK: - Validation
    
    /// Valide le formulaire et définit le message d'erreur approprié
    private func validateForm() -> Bool {
        // Vérifier que tous les champs obligatoires sont remplis
        if description.trimmingCharacters(in: .whitespaces).isEmpty {
            validationMessage = L(CommonTranslations.requiredFields)
            return false
        }
        
        if selectedVehicleId == nil {
            validationMessage = L(CommonTranslations.requiredFields)
            return false
        }
        
        // Vérifier que le montant est valide
        guard let amountValue = Double(amount) else {
            validationMessage = L(CommonTranslations.invalidAmount)
            return false
        }
        
        if amountValue <= 0 {
            validationMessage = L(CommonTranslations.invalidAmount)
            return false
        }
        
        // Vérifier que la date n'est pas dans le futur (plus de 1 jour)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        if date > tomorrow {
            validationMessage = localizationService.text("La date ne peut pas être dans le futur", "Date cannot be in the future")
            return false
        }
        
        return true
    }
}

// Explications pédagogiques :
// - L'utilisateur choisit le véhicule associé à la dépense.
// - Les identifiants d'accessibilité facilitent les tests et l'accessibilité.
// - Les textes sont maintenant localisés avec LocalizationService.

#Preview {
    AddExpenseView(vehicles: [
        Vehicle(brand: "Toyota", model: "Corolla", year: 2020, licensePlate: "AB-123-CD", mileage: 50000, fuelType: .diesel, transmission: .manual, color: "Gris", purchaseDate: Date(), purchasePrice: 18000, purchaseMileage: 0)
    ]) { expense in
        print(expense)
    }
} 