import SwiftUI

struct ProfileSectionDetailView: View {
    let section: ProfileSection
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profileService = UserProfileService.shared
    @State private var profile: UserProfile
    
    init(section: ProfileSection) {
        self.section = section
        _profile = State(initialValue: UserProfileService.shared.userProfile)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                switch section {
                case .personalInfo:
                    personalInfoSection
                case .address:
                    addressSection
                case .drivingLicense:
                    drivingLicenseSection
                case .insurance:
                    insuranceSection
                case .professional:
                    professionalSection
                case .preferences:
                    preferencesSection
                case .financial:
                    financialSection
                }
            }
            .navigationTitle(section.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        profileService.updateProfile(profile)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Informations personnelles
    private var personalInfoSection: some View {
        Section {
            TextField("Prénom", text: $profile.firstName)
            TextField("Nom", text: $profile.lastName)
            TextField("Email", text: $profile.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            TextField("Téléphone", text: $profile.phoneNumber)
                .keyboardType(.phonePad)
            
            DatePicker(
                "Date de naissance",
                selection: Binding(
                    get: { profile.dateOfBirth ?? Date() },
                    set: { profile.dateOfBirth = $0 }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
        } footer: {
            Text("Ces informations sont utilisées pour vos documents officiels et vos assurances. L'email sert pour les notifications importantes.")
        }
    }    
    // MARK: - Adresse
    private var addressSection: some View {
        Section {
            TextField("Numéro et rue", text: $profile.streetAddress)
            TextField("Ville", text: $profile.city)
            TextField("Code postal", text: $profile.postalCode)
                .keyboardType(.numberPad)
            TextField("Pays", text: $profile.country)
        } footer: {
            Text("Votre adresse est utilisée pour localiser les garages les plus proches et pour vos documents officiels.")
        }
    }
    
    // MARK: - Permis de conduire
    private var drivingLicenseSection: some View {
        Group {
            Section {
                TextField("Numéro de permis", text: $profile.drivingLicenseNumber)
                    .textInputAutocapitalization(.characters)
                
                DatePicker(
                    "Date d'obtention",
                    selection: Binding(
                        get: { profile.licenseObtainedDate ?? Date() },
                        set: { profile.licenseObtainedDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                
                DatePicker(
                    "Date d'expiration",
                    selection: Binding(
                        get: { profile.licenseExpirationDate ?? Calendar.current.date(byAdding: .year, value: 15, to: Date()) ?? Date() },
                        set: { profile.licenseExpirationDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
            } header: {
                Text("Informations du permis")
            } footer: {
                Text("Ces informations sont essentielles pour la location de véhicules et les contrôles routiers.")
            }
            
            Section {
                ForEach(licenseCategories, id: \.self) { category in
                    HStack {
                        Text("Catégorie \(category.code)")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { profile.licenseCategories.contains(category.code) },
                            set: { isSelected in
                                if isSelected {
                                    if !profile.licenseCategories.contains(category.code) {
                                        profile.licenseCategories.append(category.code)
                                    }
                                } else {
                                    profile.licenseCategories.removeAll { $0 == category.code }
                                }
                            }
                        ))
                    }
                    
                    if !category.description.isEmpty {
                        Text(category.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Catégories autorisées")
            } footer: {
                Text("Sélectionnez les catégories de véhicules que vous êtes autorisé(e) à conduire.")
            }
        }
    }    
    // MARK: - Assurance
    private var insuranceSection: some View {
        Section {
            TextField("Compagnie d'assurance", text: $profile.insuranceCompany)
            TextField("Numéro de police", text: $profile.insurancePolicyNumber)
                .textInputAutocapitalization(.characters)
            TextField("Téléphone assurance", text: $profile.insuranceContactPhone)
                .keyboardType(.phonePad)
            
            DatePicker(
                "Date d'expiration",
                selection: Binding(
                    get: { profile.insuranceExpirationDate ?? Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date() },
                    set: { profile.insuranceExpirationDate = $0 }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
        } footer: {
            Text("Ces informations sont cruciales en cas d'accident ou de sinistre. Vous recevrez des rappels avant l'expiration.")
        }
    }
    
    // MARK: - Informations professionnelles
    private var professionalSection: some View {
        Section {
            TextField("Profession", text: $profile.profession)
            TextField("Entreprise", text: $profile.company)
            
            HStack {
                Text("Usage professionnel")
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(Int(profile.professionalVehicleUsagePercentage))%")
                    .foregroundColor(.secondary)
            }
            
            Slider(
                value: $profile.professionalVehicleUsagePercentage,
                in: 0...100,
                step: 5
            ) {
                Text("Usage professionnel")
            } minimumValueLabel: {
                Text("0%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } maximumValueLabel: {
                Text("100%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } footer: {
            Text("Le pourcentage d'usage professionnel est utilisé pour calculer les déductions fiscales et la répartition des frais.")
        }
    }
    
    // MARK: - Préférences
    private var preferencesSection: some View {
        Group {
            Section {
                Picker("Devise", selection: $profile.preferredCurrency) {
                    Text("Euro (€)").tag("EUR")
                    Text("Dollar ($)").tag("USD")
                    Text("Livre (£)").tag("GBP")
                    Text("Franc suisse (CHF)").tag("CHF")
                }
                
                Picker("Unité de distance", selection: $profile.distanceUnit) {
                    ForEach(DistanceUnit.allCases, id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                
                Picker("Consommation carburant", selection: $profile.fuelConsumptionUnit) {
                    ForEach(FuelConsumptionUnit.allCases, id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                
                Picker("Langue", selection: $profile.language) {
                    Text("Français").tag("fr")
                    Text("English").tag("en")
                    Text("Español").tag("es")
                    Text("Deutsch").tag("de")
                }
            } header: {
                Text("Unités et langue")
            }
            
            Section {
                Toggle("Notifications", isOn: $profile.enableNotifications)
                Toggle("Rappels maintenance", isOn: $profile.enableMaintenanceReminders)
                Toggle("Rappels assurance", isOn: $profile.enableInsuranceReminders)
                Toggle("Rappels permis", isOn: $profile.enableLicenseReminders)
            } header: {
                Text("Notifications")
            } footer: {
                Text("Activez les notifications pour ne manquer aucune échéance importante.")
            }
        }
    }    
    // MARK: - Paramètres financiers
    private var financialSection: some View {
        Section {
            HStack {
                Text("Taux de TVA")
                    .fontWeight(.medium)
                
                Spacer()
                
                TextField("TVA", value: $profile.defaultVATRate, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(width: 60)
                    .multilineTextAlignment(.trailing)
                
                Text("%")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Déduction professionnelle")
                    .fontWeight(.medium)
                
                Spacer()
                
                TextField("Déduction", value: $profile.professionalDeductionRate, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(width: 60)
                    .multilineTextAlignment(.trailing)
                
                Text("%")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Budget mensuel véhicule")
                    .fontWeight(.medium)
                
                Spacer()
                
                TextField("Budget", value: $profile.monthlyVehicleBudget, format: .currency(code: profile.preferredCurrency))
                    .keyboardType(.decimalPad)
                    .frame(width: 100)
                    .multilineTextAlignment(.trailing)
            }
        } footer: {
            Text("Ces paramètres sont utilisés pour les calculs automatiques de coûts et les rapports financiers.")
        }
    }
    
    // MARK: - Données de support
    private let licenseCategories = [
        LicenseCategory(code: "A", description: "Motos"),
        LicenseCategory(code: "B", description: "Voitures particulières"),
        LicenseCategory(code: "C", description: "Poids lourds"),
        LicenseCategory(code: "D", description: "Transport en commun"),
        LicenseCategory(code: "BE", description: "Voiture avec remorque"),
        LicenseCategory(code: "CE", description: "Poids lourd avec remorque")
    ]
}

// MARK: - Structure de support
private struct LicenseCategory: Hashable {
    let code: String
    let description: String
}

#Preview {
    ProfileSectionDetailView(section: .personalInfo)
}