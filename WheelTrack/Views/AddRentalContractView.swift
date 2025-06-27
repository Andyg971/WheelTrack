import SwiftUI

struct AddRentalContractView: View {
    let vehicle: Vehicle
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var rentalService = RentalService.shared
    @EnvironmentObject var localizationService: LocalizationService
    
    // Champs du formulaire
    @State private var renterName = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var pricePerDay = ""
    @State private var depositAmount = ""
    @State private var conditionReport = ""
    
    // État du formulaire
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var isLoading = false
    
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
        startDate < endDate &&
        !conditionReport.trimmingCharacters(in: .whitespaces).isEmpty
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
            .onAppear {
                // Initialiser les valeurs avec celles du véhicule si disponibles
                if let vehiclePrice = vehicle.rentalPrice {
                    pricePerDay = String(format: "%.0f", vehiclePrice)
                }
                if let vehicleDeposit = vehicle.depositAmount {
                    depositAmount = String(format: "%.0f", vehicleDeposit)
                }
            }
            .navigationTitle(L(("Nouveau contrat", "New contract")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L(CommonTranslations.cancel)) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L(CommonTranslations.save)) {
                        saveContract()
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
            }
            .padding(20)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
        }
        .padding(.horizontal, 20)
    }
    
    private var renterInfoSection: some View {
        FormSection(title: L(("Informations du locataire", "Renter information")), icon: "person.fill") {
            TextField(L(("Nom complet du locataire", "Renter full name")), text: $renterName)
                .textFieldStyle(ModernTextFieldStyle())
        }
    }
    
    private var datesSection: some View {
        FormSection(title: L(("Période de location", "Rental period")), icon: "calendar") {
            VStack(spacing: 16) {
                                        DatePicker(L(("Date de début", "Start date")), selection: $startDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .environment(\.locale, Locale(identifier: localizationService.currentLanguage == "fr" ? "fr_FR" : "en_US"))
                        
                        DatePicker(L(("Date de fin", "End date")), selection: $endDate, displayedComponents: .date)
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
                
                HStack {
                    Text(L(("Caution", "Deposit")))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    TextField("0", text: $depositAmount)
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
        FormSection(title: L(("État des lieux", "Condition report")), icon: "doc.text.fill") {
            VStack(alignment: .leading, spacing: 12) {
                Text(L(("Décrivez l'état du véhicule au moment de la prise en charge", "Describe the vehicle's condition at the time of pickup")))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $conditionReport)
                    .frame(minHeight: 100)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            }
        }
    }
    
    // MARK: - Actions
    
    private func saveContract() {
        guard let pricePerDayValue = Double(pricePerDay) else { return }
        
        isLoading = true
        
        let depositValue = Double(depositAmount) ?? 0.0
        
        let contract = RentalContract(
            vehicleId: vehicle.id,
            renterName: renterName.trimmingCharacters(in: .whitespaces),
            startDate: startDate,
            endDate: endDate,
            pricePerDay: pricePerDayValue,
            conditionReport: conditionReport.trimmingCharacters(in: .whitespaces),
            depositAmount: depositValue
        )
        
        let validation = rentalService.validateContract(contract)
        
        if validation.isValid {
            rentalService.addRentalContract(contract)
            dismiss()
        } else {
            validationMessage = validation.errorMessage ?? L(("Erreur inconnue", "Unknown error"))
            showingValidationAlert = true
        }
        
        isLoading = false
    }
}

// MARK: - Supporting Views

struct FormSection<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    init(title: String, icon: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            content()
        }
        .padding(20)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
    }
}

#Preview {
    AddRentalContractView(vehicle: Vehicle(
        brand: "BMW",
        model: "X3",
        year: 2022,
        licensePlate: "AB-123-CD",
        mileage: 15000,
        fuelType: .gasoline,
        transmission: .automatic,
        color: "Noir",
        purchaseDate: Date(),
        purchasePrice: 45000,
        purchaseMileage: 10000
    ))
} 