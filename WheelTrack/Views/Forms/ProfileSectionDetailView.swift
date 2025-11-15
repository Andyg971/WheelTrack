import SwiftUI

struct ProfileSectionDetailView: View {
    let section: ProfileSection
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationService: LocalizationService
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
            .navigationTitle(section.localizedName())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L(CommonTranslations.cancel)) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L(CommonTranslations.save)) {
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
            TextField(L(CommonTranslations.firstName), text: $profile.firstName)
            TextField(L(CommonTranslations.lastName), text: $profile.lastName)
            TextField(L(CommonTranslations.email), text: $profile.email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
            TextField(L(CommonTranslations.phoneNumber), text: $profile.phoneNumber)
                .keyboardType(.phonePad)
            
            DatePicker(
                L(CommonTranslations.dateOfBirth),
                selection: Binding(
                    get: { profile.dateOfBirth ?? Date() },
                    set: { profile.dateOfBirth = $0 }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
        } footer: {
            Text(L(CommonTranslations.personalInfoFooter))
        }
    }    
    // MARK: - Adresse
    private var addressSection: some View {
        Section {
            TextField(L(CommonTranslations.streetAndNumber), text: $profile.streetAddress)
            TextField(L(CommonTranslations.city), text: $profile.city)
            TextField(L(CommonTranslations.postalCode), text: $profile.postalCode)
                .keyboardType(.numberPad)
            TextField(L(CommonTranslations.country), text: $profile.country)
        } footer: {
            Text(L(CommonTranslations.addressFooter))
        }
    }
    
    // MARK: - Permis de conduire
    private var drivingLicenseSection: some View {
        Group {
            Section {
                TextField(L(CommonTranslations.drivingLicenseNumber), text: $profile.drivingLicenseNumber)
                    .textInputAutocapitalization(.characters)
                
                DatePicker(
                    L(CommonTranslations.licenseObtainedDate),
                    selection: Binding(
                        get: { profile.licenseObtainedDate ?? Date() },
                        set: { profile.licenseObtainedDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                
                DatePicker(
                    L(CommonTranslations.licenseExpirationDate),
                    selection: Binding(
                        get: { profile.licenseExpirationDate ?? Calendar.current.date(byAdding: .year, value: 15, to: Date()) ?? Date() },
                        set: { profile.licenseExpirationDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
            } header: {
                Text(L(CommonTranslations.licenseInformation))
            } footer: {
                Text(L(CommonTranslations.licenseInfoFooter))
            }
            
            Section {
                ForEach(licenseCategories) { categoryItem in
                    HStack {
                        Text("\(L(CommonTranslations.category)) \(categoryItem.code)")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { profile.licenseCategories.contains(categoryItem.code) },
                            set: { isSelected in
                                if isSelected {
                                    if !profile.licenseCategories.contains(categoryItem.code) {
                                        profile.licenseCategories.append(categoryItem.code)
                                    }
                                } else {
                                    profile.licenseCategories.removeAll { $0 == categoryItem.code }
                                }
                            }
                        ))
                    }
                    
                    if !categoryItem.localizedDescription(localizationService).isEmpty {
                        Text(categoryItem.localizedDescription(localizationService))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text(L(CommonTranslations.authorizedCategories))
            } footer: {
                Text(L(CommonTranslations.licenseCategoriesFooter))
            }
        }
    }    
    // MARK: - Assurance
    private var insuranceSection: some View {
        Section {
            TextField(L(CommonTranslations.insuranceCompany), text: $profile.insuranceCompany)
            TextField(L(CommonTranslations.policyNumber), text: $profile.insurancePolicyNumber)
                .textInputAutocapitalization(.characters)
            TextField(L(CommonTranslations.insuranceContactPhone), text: $profile.insuranceContactPhone)
                .keyboardType(.phonePad)
            
            DatePicker(
                L(CommonTranslations.insuranceExpirationDate),
                selection: Binding(
                    get: { profile.insuranceExpirationDate ?? Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date() },
                    set: { profile.insuranceExpirationDate = $0 }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
        } footer: {
            Text(L(CommonTranslations.insuranceFooter))
        }
    }
    
    // MARK: - Informations professionnelles
    private var professionalSection: some View {
        Section {
            TextField(L(CommonTranslations.profession), text: $profile.profession)
            TextField(L(CommonTranslations.company), text: $profile.company)
            
            HStack {
                Text(L(CommonTranslations.professionalUse))
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
                Text(L(CommonTranslations.professionalUse))
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
            Text(L(CommonTranslations.professionalUseFooter))
        }
    }
    
    // MARK: - Préférences
    private var preferencesSection: some View {
        Group {
            Section {
                Picker(L(CommonTranslations.currency), selection: $profile.preferredCurrency) {
                    Text(L(CommonTranslations.euroCurrency)).tag("EUR")
                    Text(L(CommonTranslations.dollarCurrency)).tag("USD")
                    Text(L(CommonTranslations.poundCurrency)).tag("GBP")
                    Text(L(CommonTranslations.swissFrancCurrency)).tag("CHF")
                }
                
                Picker(L(CommonTranslations.distanceUnit), selection: $profile.distanceUnit) {
                    ForEach(DistanceUnit.allCases, id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                
                Picker(L(CommonTranslations.fuelConsumption), selection: $profile.fuelConsumptionUnit) {
                    ForEach(FuelConsumptionUnit.allCases, id: \.self) { unit in
                        Text(unit.displayName).tag(unit)
                    }
                }
                
                Picker(L(CommonTranslations.languageSetting), selection: $profile.language) {
                    Text(L(CommonTranslations.french)).tag("fr")
                    Text(L(CommonTranslations.english)).tag("en")
                    Text(L(CommonTranslations.spanish)).tag("es")
                    Text(L(CommonTranslations.german)).tag("de")
                }
            } header: {
                Text(L(CommonTranslations.unitsAndLanguage))
            }
            
            Section {
                Toggle(L(CommonTranslations.notifications), isOn: $profile.enableNotifications)
                Toggle(L(CommonTranslations.maintenanceReminders), isOn: $profile.enableMaintenanceReminders)
                Toggle(L(CommonTranslations.insuranceReminders), isOn: $profile.enableInsuranceReminders)
                Toggle(L(CommonTranslations.licenseReminders), isOn: $profile.enableLicenseReminders)
            } header: {
                Text(L(CommonTranslations.notifications))
            } footer: {
                Text(L(CommonTranslations.notificationsFooter))
            }
        }
    }    
    // MARK: - Paramètres financiers
    private var financialSection: some View {
        Section {
            HStack {
                Text(L(CommonTranslations.vatRate))
                    .fontWeight(.medium)
                
                Spacer()
                
                TextField(L(CommonTranslations.vat), value: $profile.defaultVATRate, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(width: 60)
                    .multilineTextAlignment(.trailing)
                
                Text("%")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(L(CommonTranslations.professionalDeduction))
                    .fontWeight(.medium)
                
                Spacer()
                
                TextField(L(CommonTranslations.deduction), value: $profile.professionalDeductionRate, format: .number)
                    .keyboardType(.decimalPad)
                    .frame(width: 60)
                    .multilineTextAlignment(.trailing)
                
                Text("%")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text(L(CommonTranslations.monthlyVehicleBudget))
                    .fontWeight(.medium)
                
                Spacer()
                
                TextField(L(CommonTranslations.budget), value: $profile.monthlyVehicleBudget, format: .currency(code: profile.preferredCurrency))
                    .keyboardType(.decimalPad)
                    .frame(width: 100)
                    .multilineTextAlignment(.trailing)
            }
        } footer: {
            Text(L(CommonTranslations.financialFooter))
        }
    }
    
    // MARK: - Données de support
    private let licenseCategories = [
        LicenseCategory(code: "A", translationKey: CommonTranslations.licenseCategoryA),
        LicenseCategory(code: "B", translationKey: CommonTranslations.licenseCategoryB),
        LicenseCategory(code: "C", translationKey: CommonTranslations.licenseCategoryC),
        LicenseCategory(code: "D", translationKey: CommonTranslations.licenseCategoryD),
        LicenseCategory(code: "BE", translationKey: CommonTranslations.licenseCategoryBE),
        LicenseCategory(code: "CE", translationKey: CommonTranslations.licenseCategoryCE)
    ]
}

// MARK: - Structure de support
private struct LicenseCategory: Identifiable {
    let id: String
    let code: String
    let frenchDescription: String
    let englishDescription: String
    
    init(code: String, translationKey: (String, String)) {
        self.id = code
        self.code = code
        self.frenchDescription = translationKey.0
        self.englishDescription = translationKey.1
    }
    
    func localizedDescription(_ localizationService: LocalizationService) -> String {
        return localizationService.text(frenchDescription, englishDescription)
    }
}

#Preview {
    ProfileSectionDetailView(section: .personalInfo)
        .environmentObject(LocalizationService.shared)
}