import SwiftUI

struct EditRentalContractView: View {
    let contract: RentalContract
    let vehicle: Vehicle
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var localizationService: LocalizationService
    private var rentalService: RentalService { RentalService.shared }
    
    // Champs du formulaire
    @State private var renterName: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var pricePerDay: String
    @State private var conditionReport: String
    
    // État du formulaire
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var isLoading = false
    
    init(contract: RentalContract, vehicle: Vehicle) {
        self.contract = contract
        self.vehicle = vehicle
        
        // Initialiser les states avec les valeurs du contrat
        self._renterName = State(initialValue: contract.renterName)
        self._startDate = State(initialValue: contract.startDate)
        self._endDate = State(initialValue: contract.endDate)
        self._pricePerDay = State(initialValue: String(contract.pricePerDay))
        self._conditionReport = State(initialValue: contract.conditionReport)
    }
    
    // Calculé automatiquement
    private var totalPrice: Double {
        guard let price = Double(pricePerDay) else { return 0 }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        return Double(days) * price
    }
    
    private var numberOfDays: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    private var isFormValid: Bool {
        !renterName.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(pricePerDay) != nil &&
        Double(pricePerDay) ?? 0 > 0 &&
        startDate < endDate
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // En-tête du véhicule
                        vehicleHeaderView
                        
                        // Formulaire principal
                        VStack(spacing: 20) {
                            renterInfoSection
                            datesSection
                            pricingSection
                            conditionSection
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle(L(CommonTranslations.modifyContract))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L(CommonTranslations.cancel)) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L(CommonTranslations.saveChanges)) {
                        updateContract()
                    }
                    .disabled(!isFormValid || isLoading)
                }
            }
            .alert(L(CommonTranslations.validation), isPresented: $showingValidationAlert) {
                Button("OK") { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    // MARK: - Vue Components
    
    private var vehicleHeaderView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "car.2.fill")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(vehicle.brand) \(vehicle.model)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(vehicle.licensePlate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("\(String(vehicle.year)) • \(vehicle.color)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Badge de statut
                Text(contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty ? "À compléter" : contract.getStatus())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor)
                    .clipShape(Capsule())
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        }
        .padding(.horizontal, 20)
    }
    
    private var statusColor: Color {
        // ✅ Vérifier si c'est un contrat pré-rempli
        if contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty {
            return .orange
        }
        
        switch contract.getStatus() {
        case "Actif":
            return .green
        case "À venir":
            return .blue
        default:
            return .gray
        }
    }
    
    private var renterInfoSection: some View {
        FormSection(title: L(CommonTranslations.renterInformation), icon: "person.fill") {
            TextField(L(CommonTranslations.renterFullName), text: $renterName)
                .textFieldStyle(ModernTextFieldStyle())
        }
    }
    
    private var datesSection: some View {
        FormSection(title: L(CommonTranslations.rentalPeriod), icon: "calendar") {
            VStack(spacing: 16) {
                DatePicker(L(CommonTranslations.startDate), selection: $startDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .environment(\.locale, Locale(identifier: localizationService.currentLanguage == "fr" ? "fr_FR" : "en_US"))
                
                DatePicker(L(CommonTranslations.endDate), selection: $endDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .environment(\.locale, Locale(identifier: localizationService.currentLanguage == "fr" ? "fr_FR" : "en_US"))
                
                if numberOfDays > 0 {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.blue)
                        
                        Text("\(L(CommonTranslations.duration)) \(numberOfDays) \(numberOfDays > 1 ? L(CommonTranslations.daysPlural) : L(CommonTranslations.days))")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    private var pricingSection: some View {
        FormSection(title: L(CommonTranslations.pricing), icon: "eurosign.circle.fill") {
            VStack(spacing: 16) {
                HStack {
                    Text(L(CommonTranslations.pricePerDay))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    TextField("0", text: $pricePerDay)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(ModernTextFieldStyle())
                        .frame(width: 120)
                        .multilineTextAlignment(.trailing)
                    
                    Text("€")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if totalPrice > 0 {
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L(CommonTranslations.totalRental))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            Text("\(numberOfDays) \(numberOfDays > 1 ? L(CommonTranslations.daysPlural) : L(CommonTranslations.days)) × \(pricePerDay)€")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.2f €", totalPrice))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    private var conditionSection: some View {
        FormSection(title: L(("État des lieux", "Condition report")), icon: "doc.text") {
            TextField(L(("État du véhicule, dommages éventuels...", "Vehicle condition, potential damages...")), text: $conditionReport, axis: .vertical)
                .textFieldStyle(ModernTextFieldStyle())
                .lineLimit(4, reservesSpace: true)
        }
    }
    
    // MARK: - Actions
    
    private func updateContract() {
        isLoading = true
        
        guard let priceValue = Double(pricePerDay) else {
            showValidationAlert(message: L(("Veuillez saisir un prix valide", "Please enter a valid price")))
            return
        }
        
        guard startDate < endDate else {
            showValidationAlert(message: L(("La date de début doit être antérieure à la date de fin", "Start date must be before end date")))
            return
        }
        
        // Créer le contrat mis à jour avec le même ID
        let updatedContract = RentalContract(
            id: contract.id,
            vehicleId: contract.vehicleId,
            renterName: renterName.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            endDate: endDate,
            pricePerDay: priceValue,
            totalPrice: totalPrice,
            conditionReport: conditionReport.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        // Valider le contrat
        let validation = rentalService.validateContract(updatedContract)
        guard validation.isValid else {
            showValidationAlert(message: validation.errorMessage ?? L(("Erreur de validation", "Validation error")))
            return
        }
        
        // Mettre à jour le contrat
        rentalService.updateRentalContract(updatedContract)
        
        isLoading = false
        dismiss()
    }
    
    private func showValidationAlert(message: String) {
        validationMessage = message
        showingValidationAlert = true
        isLoading = false
    }
}

#Preview {
    let sampleVehicle = Vehicle(
        id: UUID(),
        brand: "BMW",
        model: "Serie 3",
        year: 2020,
        licensePlate: "AB-123-CD",
        mileage: 25000,
        fuelType: .gasoline,
        transmission: .automatic,
        color: "Noir",
        purchaseDate: Date(),
        purchasePrice: 25000,
        purchaseMileage: 20000
    )
    
    let sampleContract = RentalContract(
        vehicleId: sampleVehicle.id,
        renterName: "Jean Dupont",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        pricePerDay: 45.0,
        conditionReport: "Véhicule en bon état"
    )
    
    EditRentalContractView(contract: sampleContract, vehicle: sampleVehicle)
} 