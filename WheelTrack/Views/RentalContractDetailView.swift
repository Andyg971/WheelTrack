import SwiftUI
import PDFKit

struct RentalContractDetailView: View {
    let contract: RentalContract
    let vehicle: Vehicle
    @Environment(\.dismiss) private var dismiss
    @StateObject private var rentalService = RentalService.shared
    @State private var showingDeleteAlert = false
    @State private var showingEditView = false
    @State private var isGeneratingPDF = false
    @State private var showingCompleteContractView = false
    @AppStorage("app_language") private var appLanguage = "fr"
    
    // Détermine si c'est un contrat prérempli
    private var isPrefilledContract: Bool {
        contract.renterName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var statusColor: Color {
        if isPrefilledContract {
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
    
    private var statusText: String {
        if isPrefilledContract {
            return L(("À compléter", "To complete"))
        }
        return contract.getStatus()
    }
    
    private var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: contract.startDate)
    }
    
    private var formattedEndDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: contract.endDate)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header avec statut
                        statusHeaderView
                        
                        if isPrefilledContract {
                            // Bannière d'information pour contrat prérempli
                            prefilledContractBanner
                        }
                        
                        // Informations principales
                        VStack(spacing: 20) {
                            if !isPrefilledContract {
                                renterInfoCard
                            }
                            vehicleInfoCard
                            datesInfoCard
                            pricingInfoCard
                            conditionReportCard
                        }
                        .padding(.horizontal, 20)
                        
                        // Actions
                        actionButtonsView
                            .padding(.horizontal, 20)
                            .padding(.bottom, 32)
                    }
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle(isPrefilledContract ? L(("Contrat à compléter", "Contract to complete")) : L(("Détails du contrat", "Contract details")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if isPrefilledContract {
                            Button {
                                showingCompleteContractView = true
                            } label: {
                                Label(L(("Compléter le contrat", "Complete contract")), systemImage: "person.badge.plus")
                            }
                        } else {
                            Button {
                                showingEditView = true
                            } label: {
                                Label(L(("Modifier", "Edit")), systemImage: "pencil")
                            }
                            
                            Button {
                                generatePDF()
                            } label: {
                                Label(L(("Générer PDF", "Generate PDF")), systemImage: "doc.fill")
                            }
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label(L(("Supprimer", "Delete")), systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                    }
                }
            }
            .alert(L(("Supprimer le contrat", "Delete contract")), isPresented: $showingDeleteAlert) {
                Button(L(("Supprimer", "Delete")), role: .destructive) {
                    deleteContract()
                }
                Button(L(CommonTranslations.cancel), role: .cancel) { }
            } message: {
                Text(L(("Êtes-vous sûr de vouloir supprimer ce contrat de location ? Cette action est irréversible.", "Are you sure you want to delete this rental contract? This action is irreversible.")))
            }
            .sheet(isPresented: $showingEditView) {
                EditRentalContractView(contract: contract, vehicle: vehicle)
            }
            .sheet(isPresented: $showingCompleteContractView) {
                CompletePrefilledContractViewLocal(contract: contract, vehicle: vehicle)
            }
        }
    }
    
    // MARK: - View Components
    
    private var statusHeaderView: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: isPrefilledContract ? "doc.badge.plus" : "doc.text.fill")
                    .font(.title)
                    .foregroundColor(statusColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(isPrefilledContract ? L(("Contrat à compléter", "Contract to complete")) : L(("Contrat de location", "Rental Contract")))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(statusText)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.1))
                        .clipShape(Capsule())
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
    
    private var prefilledContractBanner: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(L(("Contrat prêt à être complété", "Contract ready to be completed")))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(L(("Ce contrat a été créé automatiquement avec les paramètres de location du véhicule. Ajoutez un locataire pour l'activer.", "This contract was automatically created with the vehicle's rental parameters. Add a renter to activate it.")))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
            }
            
            Button {
                showingCompleteContractView = true
            } label: {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text(L(("Ajouter un locataire", "Add a renter")))
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .padding(20)
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
    
    private var renterInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                
                Text(L(("Locataire", "Renter")))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: L(("Nom", "Name")), value: contract.renterName)
                InfoRow(label: L(("ID du contrat", "Contract ID")), value: contract.id.uuidString.prefix(8).uppercased())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private var vehicleInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "car.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                    .frame(width: 24, height: 24)
                
                Text(L(("Véhicule", "Vehicle")))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: L(("Modèle", "Model")), value: "\(vehicle.brand) \(vehicle.model)")
                InfoRow(label: L(("Immatriculation", "License Plate")), value: vehicle.licensePlate)
                InfoRow(label: L(("Année", "Year")), value: "\(vehicle.year)")
                InfoRow(label: L(("Couleur", "Color")), value: vehicle.color)
                
                // Afficher les informations de location si disponibles
                if let depositAmount = vehicle.depositAmount {
                    InfoRow(label: L(("Caution", "Deposit")), value: String(format: "%.0f €", depositAmount))
                }
                if let minDays = vehicle.minimumRentalDays {
                    InfoRow(label: L(("Durée minimum", "Minimum duration")), value: "\(minDays) \(L((minDays > 1 ? "jours" : "jour", minDays > 1 ? "days" : "day")))")
                }
                if let maxDays = vehicle.maximumRentalDays {
                    InfoRow(label: L(("Durée maximum", "Maximum duration")), value: "\(maxDays) \(L((maxDays > 1 ? "jours" : "jour", maxDays > 1 ? "days" : "day")))")
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private var datesInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.orange)
                    .frame(width: 24, height: 24)
                
                Text(L(("Période", "Period")))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: L(("Date de début", "Start date")), value: formattedStartDate)
                InfoRow(label: L(("Date de fin", "End date")), value: formattedEndDate)
                InfoRow(label: L(("Durée", "Duration")), value: "\(contract.numberOfDays) \(L((contract.numberOfDays > 1 ? "jours" : "jour", contract.numberOfDays > 1 ? "days" : "day")))")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private var pricingInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "eurosign.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                    .frame(width: 24, height: 24)
                
                Text(L(("Tarification", "Pricing")))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(label: "Prix par jour", value: String(format: "%.2f €", contract.pricePerDay))
                InfoRow(label: "Nombre de jours", value: "\(contract.numberOfDays)")
                
                if contract.depositAmount > 0 {
                    InfoRow(label: "Caution", value: String(format: "%.2f €", contract.depositAmount))
                }
                
                Divider()
                
                HStack {
                    Text("Total")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(String(format: "%.2f €", contract.totalPrice))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private var conditionReportCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "doc.text")
                    .font(.title2)
                    .foregroundColor(.purple)
                    .frame(width: 24, height: 24)
                
                Text("État des lieux")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(contract.conditionReport.isEmpty ? "Aucun rapport d'état disponible" : contract.conditionReport)
                    .font(.body)
                    .foregroundColor(contract.conditionReport.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 16) {
            if !isPrefilledContract {
                // Bouton principal selon le statut
                if contract.isActive() {
                    Button {
                        // Action pour contrat actif (ex: finaliser)
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text(L(("Finaliser la location", "Finalize rental")))
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                
                // Boutons secondaires
                HStack(spacing: 16) {
                    Button {
                        generatePDF()
                    } label: {
                        HStack {
                            Image(systemName: "doc.fill")
                            Text(L(("Générer PDF", "Generate PDF")))
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button {
                        shareContract()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text(L(("Partager", "Share")))
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.purple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.purple.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func deleteContract() {
        rentalService.deleteRentalContract(contract)
        dismiss()
    }
    
    private func generatePDF() {
        // Ne générer le PDF que si le contrat est complété
        guard !isPrefilledContract else { return }
        
        isGeneratingPDF = true
        
        // Créer le PDF
        let pdfData = createPDFData()
        
        // Sauvegarder et partager
        if let data = pdfData {
            sharePDF(data: data)
        }
        
        isGeneratingPDF = false
    }
    
    private func createPDFData() -> Data? {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842)) // A4
        
        return pdfRenderer.pdfData { context in
            context.beginPage()
            
            let title = L(("CONTRAT DE LOCATION", "RENTAL CONTRACT")).uppercased()
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            title.draw(at: CGPoint(x: 50, y: 50), withAttributes: titleAttributes)
            
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            
            let boldAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor.black
            ]
            
            var yPosition: CGFloat = 120
            let lineHeight: CGFloat = 20
            
            // Informations du véhicule
            L(("VÉHICULE", "VEHICLE")).uppercased().draw(at: CGPoint(x: 50, y: yPosition), withAttributes: boldAttributes)
            yPosition += lineHeight + 10
            
            "\(L(("Marque et modèle", "Brand and model"))): \(vehicle.brand) \(vehicle.model)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            "\(L(("Immatriculation", "License Plate"))): \(vehicle.licensePlate)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            "\(L(("Année", "Year"))): \(vehicle.year)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            "\(L(("Couleur", "Color"))): \(vehicle.color)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight + 20
            
            // Informations du locataire
            L(("LOCATAIRE", "RENTER")).uppercased().draw(at: CGPoint(x: 50, y: yPosition), withAttributes: boldAttributes)
            yPosition += lineHeight + 10
            
            "\(L(("Nom", "Name"))): \(contract.renterName)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight + 20
            
            // Période et tarification
            L(("PÉRIODE DE LOCATION", "RENTAL PERIOD")).uppercased().draw(at: CGPoint(x: 50, y: yPosition), withAttributes: boldAttributes)
            yPosition += lineHeight + 10
            
            "\(L(("Date de début", "Start date"))): \(formattedStartDate)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            "\(L(("Date de fin", "End date"))): \(formattedEndDate)".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            "\(L(("Durée", "Duration"))): \(contract.numberOfDays) \(L((contract.numberOfDays > 1 ? "jours" : "jour", contract.numberOfDays > 1 ? "days" : "day")))".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            "\(L(("Prix par jour", "Price per day"))): \(String(format: "%.2f €", contract.pricePerDay))".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            "\(L(("TOTAL", "TOTAL"))): \(String(format: "%.2f €", contract.totalPrice))".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: boldAttributes)
            yPosition += lineHeight + 20
            
            // État des lieux
            L(("ÉTAT DES LIEUX", "CONDITION REPORT")).uppercased().draw(at: CGPoint(x: 50, y: yPosition), withAttributes: boldAttributes)
            yPosition += lineHeight + 10
            
            let conditionText = contract.conditionReport.isEmpty ? L(("Non spécifié", "Not specified")) : contract.conditionReport
            let rect = CGRect(x: 50, y: yPosition, width: 495, height: 200)
            conditionText.draw(in: rect, withAttributes: normalAttributes)
        }
    }
    
    private func sharePDF(data: Data) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("contrat_\(contract.renterName).pdf")
        
        do {
            try data.write(to: tempURL)
            
            let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                rootViewController.present(activityViewController, animated: true)
            }
        } catch {
            print("Erreur lors de la sauvegarde du PDF: \(error)")
        }
    }
    
    private func shareContract() {
        // Ne partager que si le contrat est complété
        guard !isPrefilledContract else { return }
        
        let text = """
        \(L(("CONTRAT DE LOCATION", "RENTAL CONTRACT")))
        
        \(L(("Véhicule", "Vehicle"))): \(vehicle.brand) \(vehicle.model) (\(vehicle.licensePlate))
        \(L(("Locataire", "Renter"))): \(contract.renterName)
        \(L(("Période", "Period"))): \(formattedStartDate) - \(formattedEndDate)
        \(L(("Total", "Total"))): \(String(format: "%.2f €", contract.totalPrice))
        """
        
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
}

// MARK: - Supporting Views

// InfoCard maintenant défini dans WheelTrack/Views/Components/ModernCard.swift

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - CompletePrefilledContractViewLocal

struct CompletePrefilledContractViewLocal: View {
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
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "doc.badge.plus")
                                .foregroundColor(.orange)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L(("Compléter le contrat", "Complete contract")))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text(L(("Ajoutez les informations du locataire pour activer ce contrat prérempli", "Add renter information to activate this prefilled contract")))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Résumé du contrat prérempli
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L(("Détails du contrat", "Contract details")))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            InfoSummaryRowLocal(icon: "car.fill", label: L(("Véhicule", "Vehicle")), value: "\(vehicle.brand) \(vehicle.model)")
                            InfoSummaryRowLocal(icon: "calendar", label: L(("Période", "Period")), value: formattedDateRange)
                            InfoSummaryRowLocal(icon: "eurosign.circle", label: L(("Tarif", "Rate")), value: "\(String(format: "%.0f", contract.pricePerDay))€/jour")
                            InfoSummaryRowLocal(icon: "creditcard", label: L(("Total", "Total")), value: "\(String(format: "%.0f", contract.totalPrice))€")
                            
                            if let depositAmount = vehicle.depositAmount {
                                InfoSummaryRowLocal(icon: "banknote", label: L(("Caution", "Deposit")), value: "\(String(format: "%.0f", depositAmount))€")
                            }
                        }
                        .padding(16)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                } header: {
                    Text(L(("Contrat prérempli", "Prefilled contract")))
                }
                
                Section {
                    TextField(L(("Nom complet du locataire", "Renter full name")), text: $renterName)
                        .textContentType(.name)
                    
                    TextField(L(("Téléphone (optionnel)", "Phone (optional)")), text: $renterPhone)
                        .textContentType(.telephoneNumber)
                        .keyboardType(.phonePad)
                    
                    TextField(L(("Email (optionnel)", "Email (optional)")), text: $renterEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                } header: {
                    Text(L(("Informations du locataire", "Renter information")))
                } footer: {
                    Text(L(("Seul le nom est obligatoire pour activer le contrat. Les autres informations peuvent être ajoutées plus tard.", "Only the name is required to activate the contract. Other information can be added later.")))
                        .font(.caption)
                }
                
                Section {
                    TextEditor(text: $conditionReport)
                        .frame(minHeight: 100)
                } header: {
                    Text(L(("État des lieux", "Condition report")))
                } footer: {
                    Text(L(("Décrivez l'état actuel du véhicule au moment de la remise des clés.", "Describe the current condition of the vehicle at the time of key handover.")))
                        .font(.caption)
                }
                
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L(("Activation du contrat", "Contract activation")))
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text(L(("Une fois complété, ce contrat sera automatiquement activé et visible dans la section des contrats actifs.", "Once completed, this contract will be automatically activated and visible in the active contracts section.")))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(L(("Compléter le contrat", "Complete contract")))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(L(("Activer", "Activate"))) {
                        completeContract()
                    }
                    .disabled(!isFormValid || isLoading)
                    .fontWeight(.semibold)
                }
            }
            .alert(L(("Erreur de validation", "Validation error")), isPresented: $showingValidationAlert) {
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
                        
                        Text(L(("Activation du contrat...", "Activating contract...")))
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
    
    // MARK: - Actions
    
    private func completeContract() {
        guard isFormValid else { return }
        
        isLoading = true
        
        // Mettre à jour le contrat avec les informations du locataire
        let updatedConditionReport = conditionReport.isEmpty ? 
            L(("Véhicule en bon état général. État détaillé à compléter lors de la remise des clés.", "Vehicle in good general condition. Detailed condition to be completed upon key handover.")) : 
            conditionReport
        
        let completedContract = RentalContract(
            id: contract.id,
            vehicleId: contract.vehicleId,
            renterName: renterName.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: contract.startDate,
            endDate: contract.endDate,
            pricePerDay: contract.pricePerDay,
            totalPrice: contract.totalPrice,
            conditionReport: updatedConditionReport,
            depositAmount: contract.depositAmount
        )
        
        // Valider le contrat
        let validation = rentalService.validateContract(completedContract)
        guard validation.isValid else {
            showValidationAlert(message: validation.errorMessage ?? L(("Erreur de validation", "Validation error")))
            return
        }
        
        // Sauvegarder le contrat complété
        rentalService.updateRentalContract(completedContract)
        
        // ✅ Réactivité immédiate - plus de délai
        isLoading = false
        dismiss()
    }
    
    private func showValidationAlert(message: String) {
        validationMessage = message
        showingValidationAlert = true
        isLoading = false
    }
}

struct InfoSummaryRowLocal: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.subheadline)
                .frame(width: 20)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    let sampleContract = RentalContract(
        vehicleId: UUID(),
        renterName: "Jean Dupont",
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        pricePerDay: 50.0,
        conditionReport: "Véhicule en excellent état, aucun dommage visible"
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
    
    return RentalContractDetailView(contract: sampleContract, vehicle: sampleVehicle)
} 