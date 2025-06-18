import SwiftUI

struct CompletePrefilledContractView: View {
    let contract: RentalContract
    let vehicle: Vehicle
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var rentalService = RentalService.shared
    
    // Champs du formulaire (seulement les essentiels pour compléter)
    @State private var renterName = ""
    @State private var renterPhone = ""
    @State private var renterEmail = ""
    @State private var conditionReport = ""
    
    // État du formulaire
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    @State private var isLoading = false
    
    private var isFormValid: Bool {
        !renterName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: contract.startDate)) - \(formatter.string(from: contract.endDate))"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    contractHeaderView
                    
                    Divider()
                    
                    contractSummaryView
                } header: {
                    Text("Contrat prérempli")
                }
                
                Section {
                    TextField("Nom complet du locataire", text: $renterName)
                        .textContentType(.name)
                    
                    TextField("Téléphone (optionnel)", text: $renterPhone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    
                    TextField("Email (optionnel)", text: $renterEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                } header: {
                    Text("Informations du locataire")
                } footer: {
                    Text("Seul le nom est obligatoire pour activer le contrat. Les autres informations peuvent être ajoutées plus tard.")
                        .font(.caption)
                }
                
                Section {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $conditionReport)
                            .frame(minHeight: 100)
                        
                        if conditionReport.isEmpty {
                            Text("Complétez l'état des lieux du véhicule...")
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                        }
                    }
                } header: {
                    Text("État des lieux")
                } footer: {
                    Text("Décrivez l'état actuel du véhicule au moment de la remise des clés.")
                        .font(.caption)
                }
                
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Activation du contrat")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Une fois complété, ce contrat sera automatiquement activé et visible dans la section des contrats actifs.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Compléter le contrat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Activer") {
                        completeContract()
                    }
                    .disabled(!isFormValid || isLoading)
                    .fontWeight(.semibold)
                }
            }
            .alert("Erreur de validation", isPresented: $showingValidationAlert) {
                Button("OK") { }
            } message: {
                Text(validationMessage)
            }
            .overlay {
                if isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Activation du contrat...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .padding(24)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 10)
                }
            }
        }
    }
    
    // MARK: - Computed Views
    
    private var contractHeaderView: some View {
        HStack {
            Image(systemName: "doc.badge.plus")
                .foregroundColor(.orange)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Compléter le contrat")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Ajoutez les informations du locataire pour activer ce contrat prérempli")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var contractSummaryView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Détails du contrat")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            contractDetailsRows
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var contractDetailsRows: some View {
        VStack(spacing: 8) {
            InfoSummaryRow(icon: "car.fill", label: "Véhicule", value: "\(vehicle.brand) \(vehicle.model)")
            InfoSummaryRow(icon: "calendar", label: "Période", value: formattedDateRange)
            InfoSummaryRow(icon: "eurosign.circle", label: "Tarif", value: "\(String(format: "%.0f", contract.pricePerDay))€/jour")
            InfoSummaryRow(icon: "creditcard", label: "Total", value: "\(String(format: "%.0f", contract.totalPrice))€")
            
            if let depositAmount = vehicle.depositAmount {
                InfoSummaryRow(icon: "banknote", label: "Caution", value: "\(String(format: "%.0f", depositAmount))€")
            }
        }
    }
    
    // MARK: - Actions
    
    private func completeContract() {
        guard isFormValid else { return }
        
        isLoading = true
        
        // Mettre à jour le contrat avec les informations du locataire
        let updatedConditionReport = conditionReport.isEmpty ? 
            "Véhicule en bon état général. État détaillé à compléter lors de la remise des clés." : 
            conditionReport
        
        let completedContract = RentalContract(
            id: contract.id,
            vehicleId: contract.vehicleId,
            renterName: renterName.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: contract.startDate,
            endDate: contract.endDate,
            pricePerDay: contract.pricePerDay,
            totalPrice: contract.totalPrice,
            conditionReport: updatedConditionReport
        )
        
        // Valider le contrat
        let validation = rentalService.validateContract(completedContract)
        guard validation.isValid else {
            showValidationAlert(message: validation.errorMessage ?? "Erreur de validation")
            return
        }
        
        // Mettre à jour le contrat dans le service
        rentalService.updateRentalContract(completedContract)
        
        // ✅ Réactivité immédiate - plus de délai
        isLoading = false
        
        // Feedback de succès
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)
        
        dismiss()
    }
    
    private func showValidationAlert(message: String) {
        validationMessage = message
        showingValidationAlert = true
        isLoading = false
    }
}

// MARK: - Supporting Views

struct InfoSummaryRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 20)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}



#Preview {
    let sampleContract = RentalContract(
        vehicleId: UUID(),
        renterName: "", // Contrat prérempli
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        pricePerDay: 50.0,
        conditionReport: "Véhicule en bon état général. État détaillé à compléter lors de la remise des clés."
    )
    
    let sampleVehicle = Vehicle(
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
    )
    
    return CompletePrefilledContractView(contract: sampleContract, vehicle: sampleVehicle)
} 