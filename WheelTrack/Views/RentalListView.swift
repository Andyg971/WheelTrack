import SwiftUI

struct RentalListView: View {
    let vehicle: Vehicle
    @ObservedObject private var rentalService = RentalService.shared
    @State private var showingAddRental = false
    @State private var selectedContract: RentalContract?
    @State private var showingContractDetail = false
    @State private var contractToDelete: RentalContract?
    @State private var showingDeleteAlert = false
    
    var rentalContracts: [RentalContract] {
        rentalService.getRentalContracts(for: vehicle.id)
    }
    
    var prefilledContracts: [RentalContract] {
        rentalContracts.filter { $0.renterName.trimmingCharacters(in: .whitespaces).isEmpty }
    }
    
    var completedContracts: [RentalContract] {
        rentalContracts.filter { !$0.renterName.trimmingCharacters(in: .whitespaces).isEmpty }
    }
    
    var activeContracts: [RentalContract] {
        completedContracts.filter { $0.isActive() }
    }
    
    var upcomingContracts: [RentalContract] {
        let now = Date()
        return completedContracts.filter { $0.startDate > now }
    }
    
    var expiredContracts: [RentalContract] {
        completedContracts.filter { $0.isExpired() }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if rentalContracts.isEmpty {
                    emptyStateView
                } else {
                    List {
                        // Section pour les contrats préremplis
                        if !prefilledContracts.isEmpty {
                            Section {
                                ForEach(prefilledContracts) { contract in
                                    PrefilledContractRow(contract: contract, vehicle: vehicle) {
                                        selectedContract = contract
                                        showingContractDetail = true
                                    }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        let contract = prefilledContracts[index]
                                        contractToDelete = contract
                                        showingDeleteAlert = true
                                    }
                                }
                            } header: {
                                Label(L(("Contrats prêts à compléter", "Contracts ready to complete")), systemImage: "doc.badge.plus")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        // Contrats actifs
                        if !activeContracts.isEmpty {
                            Section {
                                ForEach(activeContracts) { contract in
                                    RentalContractRow(contract: contract, statusColor: .green) {
                                        selectedContract = contract
                                        showingContractDetail = true
                                    }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        let contract = activeContracts[index]
                                        contractToDelete = contract
                                        showingDeleteAlert = true
                                    }
                                }
                            } header: {
                                Label(L(("Contrats actifs", "Active contracts")), systemImage: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        
                        // Contrats à venir
                        if !upcomingContracts.isEmpty {
                            Section {
                                ForEach(upcomingContracts) { contract in
                                    RentalContractRow(contract: contract, statusColor: .blue) {
                                        selectedContract = contract
                                        showingContractDetail = true
                                    }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        let contract = upcomingContracts[index]
                                        contractToDelete = contract
                                        showingDeleteAlert = true
                                    }
                                }
                            } header: {
                                Label(L(("Contrats à venir", "Upcoming contracts")), systemImage: "clock")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        // Contrats expirés
                        if !expiredContracts.isEmpty {
                            Section {
                                ForEach(expiredContracts) { contract in
                                    RentalContractRow(contract: contract, statusColor: .gray) {
                                        selectedContract = contract
                                        showingContractDetail = true
                                    }
                                }
                                .onDelete { indexSet in
                                    for index in indexSet {
                                        let contract = expiredContracts[index]
                                        contractToDelete = contract
                                        showingDeleteAlert = true
                                    }
                                }
                            } header: {
                                Label(L(("Contrats terminés", "Completed contracts")), systemImage: "checkmark.circle")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle(L(("Locations", "Rentals")))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddRental) {
                AddRentalContractView(vehicle: vehicle)
            }
            .navigationDestination(isPresented: $showingContractDetail) {
                if let contract = selectedContract {
                    RentalContractDetailView(contract: contract, vehicle: vehicle)
                }
            }
            .alert(L(("Supprimer le contrat", "Delete contract")), isPresented: $showingDeleteAlert) {
                Button(L(("Supprimer", "Delete")), role: .destructive) {
                    if let contract = contractToDelete {
                        deleteContract(contract)
                    }
                }
                Button(L(CommonTranslations.cancel), role: .cancel) {
                    contractToDelete = nil
                }
            } message: {
                Text(L(("Êtes-vous sûr de vouloir supprimer ce contrat de location ? Cette action est irréversible.", "Are you sure you want to delete this rental contract? This action is irreversible.")))
            }
        }
    }
    
    private func deleteContract(_ contract: RentalContract) {
        rentalService.deleteRentalContract(contract)
        contractToDelete = nil
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "car.2")
                .font(.system(size: 64))
                .foregroundColor(.blue.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(L(("Aucun contrat de location", "No rental contracts")))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(L(("Ce véhicule sera automatiquement ajouté avec un contrat prérempli si vous l'activez pour la location", "This vehicle will be automatically added with a prefilled contract if you activate it for rental")))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Button {
                showingAddRental = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(L(("Créer un contrat", "Create a contract")))
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.blue, .blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
}

// MARK: - Supporting Views

struct PrefilledContractRow: View {
    let contract: RentalContract
    let vehicle: Vehicle
    let onTap: () -> Void
    @AppStorage("app_language") private var appLanguage = "fr"
    
    private var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: appLanguage == "fr" ? "fr_FR" : "en_US")
        return "\(formatter.string(from: contract.startDate)) - \(formatter.string(from: contract.endDate))"
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "doc.badge.plus")
                        .foregroundColor(.orange)
                    Text(L(("Prêt", "Ready")))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange)
                        .clipShape(Capsule())
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                            .frame(width: 16)
                        Text(formattedDateRange)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "eurosign.circle")
                            .foregroundColor(.secondary)
                            .frame(width: 16)
                        Text("\(String(format: "%.0f", contract.pricePerDay))€/jour")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Total: \(String(format: "%.0f", contract.totalPrice))€")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                }
                
                HStack {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(.orange)
                    Text(L(("Appuyez pour ajouter un locataire", "Tap to add a renter")))
                        .font(.caption)
                        .foregroundColor(.orange)
                        .italic()
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RentalContractRow: View {
    let contract: RentalContract
    let statusColor: Color
    let onTap: () -> Void
    @AppStorage("app_language") private var appLanguage = "fr"
    
    private var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: appLanguage == "fr" ? "fr_FR" : "en_US")
        return "\(formatter.string(from: contract.startDate)) - \(formatter.string(from: contract.endDate))"
    }
    
    private var daysRemaining: String {
        let calendar = Calendar.current
        let now = Date()
        
        if contract.isActive() {
            let daysLeft = calendar.dateComponents([.day], from: now, to: contract.endDate).day ?? 0
            return L(("Se termine dans \(daysLeft) jour\(daysLeft > 1 ? "s" : "")", "Ends in \(daysLeft) day\(daysLeft > 1 ? "s" : "")"))
        } else if contract.startDate > now {
            let daysUntil = calendar.dateComponents([.day], from: now, to: contract.startDate).day ?? 0
            return L(("Commence dans \(daysUntil) jour\(daysUntil > 1 ? "s" : "")", "Starts in \(daysUntil) day\(daysUntil > 1 ? "s" : "")"))
        } else {
            let daysSince = calendar.dateComponents([.day], from: contract.endDate, to: now).day ?? 0
            return L(("Terminé depuis \(daysSince) jour\(daysSince > 1 ? "s" : "")", "Ended \(daysSince) day\(daysSince > 1 ? "s" : "") ago"))
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(contract.renterName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(contract.getStatus())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor)
                        .clipShape(Capsule())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text(formattedDateRange)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "eurosign.circle")
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.0f", contract.pricePerDay))€/jour")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Total: \(String(format: "%.0f", contract.totalPrice))€")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                        Text(daysRemaining)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        RentalListView(vehicle: Vehicle(
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
} 