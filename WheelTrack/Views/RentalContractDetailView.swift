import SwiftUI
import PDFKit

struct RentalContractDetailView: View {
    let contract: RentalContract
    let vehicle: Vehicle
    @Environment(\.dismiss) private var dismiss
    @StateObject private var rentalService = RentalService.shared
    @ObservedObject private var freemiumService = FreemiumService.shared
    @State private var showingDeleteAlert = false
    @State private var showingEditView = false
    @State private var isGeneratingPDF = false
    @State private var showingCompleteContractView = false
    @State private var pdfDataToShare: Data?
    @State private var showingShareSheet = false
    @State private var textToShare: String?
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
        formatter.locale = Locale(identifier: appLanguage == "fr" ? "fr_FR" : "en_US")
        return formatter.string(from: contract.startDate)
    }
    
    private var formattedEndDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: appLanguage == "fr" ? "fr_FR" : "en_US")
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
                
                // Overlay de chargement pour la génération du PDF
                if isGeneratingPDF {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.blue)
                        
                        Text(L(("Génération du PDF...", "Generating PDF...")))
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(L(("Veuillez patienter", "Please wait")))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    )
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
                                if freemiumService.hasAccess(to: .pdfExport) {
                                    generatePDF()
                                } else {
                                    freemiumService.requestUpgrade(for: .pdfExport)
                                }
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
            .sheet(isPresented: $freemiumService.showUpgradeAlert) {
                if let blockedFeature = freemiumService.blockedFeature {
                    NavigationView {
                        PremiumUpgradeAlert(feature: blockedFeature)
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let pdfData = pdfDataToShare {
                    ShareSheetView(activityItems: [savePDFToTemp(data: pdfData)])
                } else if let text = textToShare {
                    ShareSheetView(activityItems: [text])
                }
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
                InfoRow(label: L(("Année", "Year")), value: "\(String(vehicle.year))")
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
                        finalizeRental()
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
                        if freemiumService.hasAccess(to: .pdfExport) {
                            generatePDF()
                        } else {
                            freemiumService.requestUpgrade(for: .pdfExport)
                        }
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
    
    private func finalizeRental() {
        // Fermer la vue de détail du contrat
        dismiss()
    }
    
    private func generatePDF() {
        // Ne générer le PDF que si le contrat est complété
        guard !isPrefilledContract else { return }
        
        isGeneratingPDF = true
        
        // Créer le PDF
        if let pdfData = createPDFData() {
            // Stocker les données du PDF et afficher la feuille de partage
            self.pdfDataToShare = pdfData
            self.textToShare = nil
            self.showingShareSheet = true
        }
        
        isGeneratingPDF = false
    }
    
    // Fonction helper pour sauvegarder le PDF dans un fichier temporaire
    private func savePDFToTemp(data: Data) -> URL {
        let fileName = "Contrat_\(contract.renterName.replacingOccurrences(of: " ", with: "_"))_\(formatDateForFileName(contract.startDate)).pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempURL)
        } catch {
            print("❌ Erreur lors de la sauvegarde du PDF: \(error.localizedDescription)")
        }
        
        return tempURL
    }
    
    // Formater la date pour le nom de fichier
    private func formatDateForFileName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
    
    private func createPDFData() -> Data? {
        // Format A4 : 595 x 842 points
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595, height: 842))
        
        return pdfRenderer.pdfData { context in
            context.beginPage()
            
            // ==================== STYLES ====================
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 26),
                .foregroundColor: UIColor.systemBlue
            ]
            
            let sectionTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.darkGray
            ]
            
            let normalAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.black
            ]
            
            let boldAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 11),
                .foregroundColor: UIColor.black
            ]
            
            let totalAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.systemGreen
            ]
            
            // ==================== EN-TÊTE ====================
            var yPosition: CGFloat = 40
            let margin: CGFloat = 50
            let lineHeight: CGFloat = 18
            
            // Titre principal
            let title = L(("CONTRAT DE LOCATION", "RENTAL CONTRACT")).uppercased()
            title.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
            yPosition += 35
            
            // Date de génération et ID du contrat
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.locale = Locale(identifier: appLanguage == "fr" ? "fr_FR" : "en_US")
            
            let generationDate = L(("Document généré le", "Document generated on")) + " \(dateFormatter.string(from: Date()))"
            generationDate.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            let contractId = L(("ID du contrat", "Contract ID")) + ": \(contract.id.uuidString.prefix(8).uppercased())"
            contractId.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: normalAttributes)
            yPosition += 30
            
            // Ligne de séparation
            let separatorPath = UIBezierPath()
            separatorPath.move(to: CGPoint(x: margin, y: yPosition))
            separatorPath.addLine(to: CGPoint(x: 595 - margin, y: yPosition))
            UIColor.systemGray4.setStroke()
            separatorPath.lineWidth = 1
            separatorPath.stroke()
            yPosition += 25
            
            // ==================== SECTION VÉHICULE ====================
            L(("VÉHICULE", "VEHICLE")).uppercased().draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionTitleAttributes)
            yPosition += lineHeight + 8
            
            // Rectangle de fond pour la section
            let vehicleRect = CGRect(x: margin, y: yPosition, width: 495, height: 90)
            UIColor.systemGray6.setFill()
            UIBezierPath(roundedRect: vehicleRect, cornerRadius: 8).fill()
            
            yPosition += 10
            
            "\(L(("Marque et modèle", "Brand and model"))): \(vehicle.brand) \(vehicle.model)".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: boldAttributes)
            yPosition += lineHeight
            
            "\(L(("Immatriculation", "License Plate"))): \(vehicle.licensePlate)".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            "\(L(("Année", "Year"))): \(String(vehicle.year))  •  \(L(("Couleur", "Color"))): \(vehicle.color)".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            let fuelTypeStr = L(("Carburant", "Fuel"))+": \(vehicle.fuelType.rawValue)  •  \(L(("Transmission", "Transmission"))): \(vehicle.transmission.rawValue)"
            fuelTypeStr.draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            yPosition += 20
            
            // ==================== SECTION LOCATAIRE ====================
            L(("LOCATAIRE", "RENTER")).uppercased().draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionTitleAttributes)
            yPosition += lineHeight + 8
            
            let renterRect = CGRect(x: margin, y: yPosition, width: 495, height: 35)
            UIColor.systemBlue.withAlphaComponent(0.05).setFill()
            UIBezierPath(roundedRect: renterRect, cornerRadius: 8).fill()
            
            yPosition += 10
            
            "\(L(("Nom complet", "Full name"))): \(contract.renterName)".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: boldAttributes)
            yPosition += 35
            
            // ==================== SECTION PÉRIODE ====================
            L(("PÉRIODE DE LOCATION", "RENTAL PERIOD")).uppercased().draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionTitleAttributes)
            yPosition += lineHeight + 8
            
            let periodRect = CGRect(x: margin, y: yPosition, width: 495, height: 72)
            UIColor.systemOrange.withAlphaComponent(0.05).setFill()
            UIBezierPath(roundedRect: periodRect, cornerRadius: 8).fill()
            
            yPosition += 10
            
            "\(L(("Date de début", "Start date"))): \(formattedStartDate)".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            "\(L(("Date de fin", "End date"))): \(formattedEndDate)".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            "\(L(("Durée totale", "Total duration"))): \(contract.numberOfDays) \(L((contract.numberOfDays > 1 ? "jours" : "jour", contract.numberOfDays > 1 ? "days" : "day")))".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: boldAttributes)
            yPosition += 32
            
            // ==================== SECTION TARIFICATION ====================
            L(("TARIFICATION", "PRICING")).uppercased().draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionTitleAttributes)
            yPosition += lineHeight + 8
            
            let pricingRect = CGRect(x: margin, y: yPosition, width: 495, height: contract.depositAmount > 0 ? 90 : 72)
            UIColor.systemGreen.withAlphaComponent(0.05).setFill()
            UIBezierPath(roundedRect: pricingRect, cornerRadius: 8).fill()
            
            yPosition += 10
            
            "\(L(("Prix par jour", "Price per day"))): \(String(format: "%.2f €", contract.pricePerDay))".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            "\(L(("Nombre de jours", "Number of days"))): \(contract.numberOfDays)".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: normalAttributes)
            yPosition += lineHeight
            
            if contract.depositAmount > 0 {
                "\(L(("Caution", "Deposit"))): \(String(format: "%.2f €", contract.depositAmount))".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: normalAttributes)
                yPosition += lineHeight
            }
            
            // Ligne de séparation
            let priceSeparator = UIBezierPath()
            priceSeparator.move(to: CGPoint(x: margin + 10, y: yPosition + 2))
            priceSeparator.addLine(to: CGPoint(x: 495 + margin - 10, y: yPosition + 2))
            UIColor.systemGray3.setStroke()
            priceSeparator.lineWidth = 1
            priceSeparator.stroke()
            yPosition += 10
            
            "\(L(("TOTAL", "TOTAL"))): \(String(format: "%.2f €", contract.totalPrice))".draw(at: CGPoint(x: margin + 10, y: yPosition), withAttributes: totalAttributes)
            yPosition += 35
            
            // ==================== SECTION ÉTAT DES LIEUX ====================
            L(("ÉTAT DES LIEUX", "CONDITION REPORT")).uppercased().draw(at: CGPoint(x: margin, y: yPosition), withAttributes: sectionTitleAttributes)
            yPosition += lineHeight + 8
            
            let conditionText = contract.conditionReport.isEmpty ? L(("Non spécifié", "Not specified")) : contract.conditionReport
            let conditionRect = CGRect(x: margin + 10, y: yPosition, width: 475, height: 842 - yPosition - 100)
            
            // Dessiner un rectangle de fond
            let conditionBg = CGRect(x: margin, y: yPosition, width: 495, height: min(150, 842 - yPosition - 80))
            UIColor.systemPurple.withAlphaComponent(0.05).setFill()
            UIBezierPath(roundedRect: conditionBg, cornerRadius: 8).fill()
            
            // Dessiner le texte avec un paragraphe style pour gérer les retours à la ligne
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 4
            paragraphStyle.alignment = .left
            
            let conditionAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            
            conditionText.draw(in: conditionRect, withAttributes: conditionAttributes)
            
            // ==================== PIED DE PAGE ====================
            let footerY: CGFloat = 842 - 50
            
            let footerSeparator = UIBezierPath()
            footerSeparator.move(to: CGPoint(x: margin, y: footerY - 10))
            footerSeparator.addLine(to: CGPoint(x: 595 - margin, y: footerY - 10))
            UIColor.systemGray4.setStroke()
            footerSeparator.lineWidth = 1
            footerSeparator.stroke()
            
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9),
                .foregroundColor: UIColor.systemGray
            ]
            
            L(("Document généré par WheelTrack", "Document generated by WheelTrack")).draw(at: CGPoint(x: margin, y: footerY), withAttributes: footerAttributes)
            
            let pageNumber = "1/1"
            let pageNumberWidth = pageNumber.size(withAttributes: footerAttributes).width
            pageNumber.draw(at: CGPoint(x: 595 - margin - pageNumberWidth, y: footerY), withAttributes: footerAttributes)
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
        
        // Utiliser le nouveau système de partage
        self.textToShare = text
        self.pdfDataToShare = nil
        self.showingShareSheet = true
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
    @State private var showImmediateStartDialog = false
    
    private var isFormValid: Bool {
        !renterName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR") // Par défaut en français pour cette vue locale
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
                        if contract.startDate > Date() {
                            showImmediateStartDialog = true
                        } else {
                            completeContract()
                        }
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
            .confirmationDialog(
                L(CommonTranslations.futureStartDate),
                isPresented: $showImmediateStartDialog,
                titleVisibility: .visible
            ) {
                Button(L(CommonTranslations.startNow)) {
                    completeContract(forceStartNow: true)
                }
                Button(L(CommonTranslations.keepPlannedDate)) {
                    completeContract(forceStartNow: false)
                }
                Button(L(CommonTranslations.cancel), role: .cancel) { }
            }
        }
    }
    
    // MARK: - Actions
    
    private func completeContract(forceStartNow: Bool = false) {
        guard isFormValid else { return }
        
        isLoading = true
        
        // Mettre à jour le contrat avec les informations du locataire
        let updatedConditionReport = conditionReport.isEmpty ? 
            L(("Véhicule en bon état général. État détaillé à compléter lors de la remise des clés.", "Vehicle in good general condition. Detailed condition to be completed upon key handover.")) : 
            conditionReport
        
        let now = Date()
        var adjustedStartDate = contract.startDate
        var adjustedEndDate = contract.endDate
        
        // Forcer l'activation immédiate si demandé et si la date de début est future
        if forceStartNow && adjustedStartDate > now {
            adjustedStartDate = now
            // Sécurité: s'assurer que la fin est après le début
            if adjustedEndDate <= adjustedStartDate {
                adjustedEndDate = Calendar.current.date(byAdding: .day, value: 1, to: adjustedStartDate) ?? adjustedStartDate.addingTimeInterval(86_400)
            }
        }
        
        let completedContract = RentalContract(
            id: contract.id,
            vehicleId: contract.vehicleId,
            renterName: renterName.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: adjustedStartDate,
            endDate: adjustedEndDate,
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

// MARK: - ShareSheetView

/// Vue pour afficher la feuille de partage native iOS
/// Permet de partager des fichiers PDF et du texte via toutes les applications installées
struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Pas de mise à jour nécessaire
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