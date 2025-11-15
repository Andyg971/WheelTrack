import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject private var localizationService: LocalizationService
    @ObservedObject private var profileService = UserProfileService.shared
    @State private var showingEditProfile = false
    @State private var selectedSection: ProfileSection? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // En-tête avec photo et infos de base
                    profileHeaderView
                    
                    // Alertes d'expiration
                    alertsSection
                    
                    // Sections du profil
                    profileSectionsView
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(L(CommonTranslations.myProfile))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(L(CommonTranslations.edit)) {
                        showingEditProfile = true
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditUserProfileView()
            }
        }
    }
    
    // MARK: - En-tête du profil
    private var profileHeaderView: some View {
        VStack(spacing: 16) {
            // Photo de profil
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                if let imageData = profileService.userProfile.profileImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            // Nom et email
            VStack(spacing: 4) {
                Text(profileService.userProfile.fullName.isEmpty ? L(CommonTranslations.nameNotProvided) : profileService.userProfile.fullName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if !profileService.userProfile.email.isEmpty {
                    Text(profileService.userProfile.email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }    
    // MARK: - Section des alertes
    private var alertsSection: some View {
        let alerts = profileService.getExpirationAlerts()
        
        return Group {
            if !alerts.isEmpty {
                VStack(spacing: 12) {
                    ForEach(alerts.indices, id: \.self) { index in
                        let alert = alerts[index]
                        
                        HStack(spacing: 12) {
                            Image(systemName: alert.priority == .high ? "exclamationmark.triangle.fill" : "clock.fill")
                                .foregroundColor(alert.priority == .high ? .red : .orange)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(alert.title)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(alert.priority == .high ? .red : .orange)
                                
                                Text(alert.message)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(16)
                        .background(
                            (alert.priority == .high ? Color.red : Color.orange)
                                .opacity(0.1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    (alert.priority == .high ? Color.red : Color.orange).opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Sections du profil
    private var profileSectionsView: some View {
        VStack(spacing: 16) {
            ForEach(ProfileSection.allCases, id: \.self) { section in
                ProfileSectionCard(
                    section: section,
                    profile: profileService.userProfile
                ) {
                    selectedSection = section
                }
            }
        }
        .sheet(item: $selectedSection) { section in
            ProfileSectionDetailView(section: section)
        }
    }
}

// MARK: - Section du profil
enum ProfileSection: String, CaseIterable, Identifiable {
    case personalInfo
    case address
    case drivingLicense
    case insurance
    case professional
    case preferences
    case financial
    
    var id: String { self.rawValue }
    
    func localizedName() -> String {
        switch self {
        case .personalInfo: return L(CommonTranslations.personalInformation)
        case .address: return L(CommonTranslations.address)
        case .drivingLicense: return L(CommonTranslations.drivingLicense)
        case .insurance: return L(CommonTranslations.mainInsurance)
        case .professional: return L(CommonTranslations.professionalInformation)
        case .preferences: return L(CommonTranslations.preferences)
        case .financial: return L(CommonTranslations.financialSettings)
        }
    }
    
    var icon: String {
        switch self {
        case .personalInfo: return "person.fill"
        case .address: return "house.fill"
        case .drivingLicense: return "creditcard.fill"
        case .insurance: return "shield.fill"
        case .professional: return "briefcase.fill"
        case .preferences: return "gear"
        case .financial: return "eurosign.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .personalInfo: return .blue
        case .address: return .green
        case .drivingLicense: return .purple
        case .insurance: return .red
        case .professional: return .orange
        case .preferences: return .gray
        case .financial: return .yellow
        }
    }
}
// MARK: - Carte de section du profil
struct ProfileSectionCard: View {
    @EnvironmentObject private var localizationService: LocalizationService
    let section: ProfileSection
    let profile: UserProfile
    let onTap: () -> Void
    
    // MARK: - Localization for status
    private static func localStatusText(_ key: String, _ language: String) -> String {
        switch (key, language) {
        case ("name_not_provided", "en"): return "Name and surname not provided"
        case ("name_not_provided", _): return "Nom et prénom non renseignés"
        case ("email_not_provided", "en"): return "Email not provided"
        case ("email_not_provided", _): return "Email non renseigné"
        case ("address_not_provided", "en"): return "Address not provided"
        case ("address_not_provided", _): return "Adresse non renseignée"
        case ("license_number_not_provided", "en"): return "License number not provided"
        case ("license_number_not_provided", _): return "Numéro de permis non renseigné"
        case ("license_expired", "en"): return "⚠️ License expired"
        case ("license_expired", _): return "⚠️ Permis expiré"
        case ("expires_in", "en"): return "⚠️ Expires in"
        case ("expires_in", _): return "⚠️ Expire dans"
        case ("day", "en"): return "day"
        case ("day", _): return "jour"
        case ("days", "en"): return "days"
        case ("days", _): return "jours"
        case ("valid_expires_on", "en"): return "Valid • Expires on"
        case ("valid_expires_on", _): return "Valide • Expire le"
        case ("expiration_date_not_provided", "en"): return "Expiration date not provided"
        case ("expiration_date_not_provided", _): return "Date d'expiration non renseignée"
        case ("insurance_company_not_provided", "en"): return "Insurance company not provided"
        case ("insurance_company_not_provided", _): return "Compagnie d'assurance non renseignée"
        case ("insurance_expired", "en"): return "⚠️ Insurance expired"
        case ("insurance_expired", _): return "⚠️ Assurance expirée"
        case ("valid", "en"): return "Valid"
        case ("valid", _): return "Valide"
        case ("professional_info_not_provided", "en"): return "Professional information not provided"
        case ("professional_info_not_provided", _): return "Informations professionnelles non renseignées"
        case ("vat", "en"): return "VAT"
        case ("vat", _): return "TVA"
        case ("budget", "en"): return "Budget"
        case ("budget", _): return "Budget"
        case ("financial_settings_to_configure", "en"): return "Financial settings to configure"
        case ("financial_settings_to_configure", _): return "Paramètres financiers à configurer"
        case ("not_provided", "en"): return "Not provided"
        case ("not_provided", _): return "Non renseignée"
        default: return key
        }
    }
    
    private func localStatusText(_ key: String) -> String {
        return Self.localStatusText(key, localizationService.currentLanguage)
    }
    
    private func localizeDistanceUnit(_ unit: DistanceUnit) -> String {
        switch (unit, localizationService.currentLanguage) {
        case (.kilometers, "en"): return "Kilometers"
        case (.kilometers, _): return "Kilomètres"
        case (.miles, "en"): return "Miles"
        case (.miles, _): return "Miles"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icône de la section
                ZStack {
                    Circle()
                        .fill(section.color.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: section.icon)
                        .font(.title2)
                        .foregroundColor(section.color)
                }
                
                // Contenu de la section
                VStack(alignment: .leading, spacing: 4) {
                    Text(section.localizedName())
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(getSectionStatus(for: section))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Indicateur de complétude
                Image(systemName: isCompletedSection(section) ? "checkmark.circle.fill" : "chevron.right")
                    .foregroundColor(isCompletedSection(section) ? .green : .secondary)
                    .font(.title3)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getSectionStatus(for section: ProfileSection) -> String {
        switch section {
        case .personalInfo:
            if profile.fullName.isEmpty {
                return localStatusText("name_not_provided")
            } else if profile.email.isEmpty {
                return localStatusText("email_not_provided")
            } else {
                return "\(profile.fullName) • \(profile.email)"
            }
            
        case .address:
            if profile.streetAddress.isEmpty {
                return localStatusText("address_not_provided")
            } else {
                return "\(profile.streetAddress), \(profile.city)"
            }
            
        case .drivingLicense:
            if profile.drivingLicenseNumber.isEmpty {
                return localStatusText("license_number_not_provided")
            } else if let days = profile.daysUntilLicenseExpiration {
                if days <= 0 {
                    return localStatusText("license_expired")
                } else if days <= 30 {
                    let dayText = days > 1 ? localStatusText("days") : localStatusText("day")
                    return "\(localStatusText("expires_in")) \(days) \(dayText)"
                } else {
                    return "\(localStatusText("valid_expires_on")) \(formatDate(profile.licenseExpirationDate))"
                }
            } else {
                return localStatusText("expiration_date_not_provided")
            }
            
        case .insurance:
            if profile.insuranceCompany.isEmpty {
                return localStatusText("insurance_company_not_provided")
            } else if let days = profile.daysUntilInsuranceExpiration {
                if days <= 0 {
                    return localStatusText("insurance_expired")
                } else if days <= 30 {
                    let dayText = days > 1 ? localStatusText("days") : localStatusText("day")
                    return "\(localStatusText("expires_in")) \(days) \(dayText)"
                } else {
                    return "\(profile.insuranceCompany) • \(localStatusText("valid"))"
                }
            } else {
                return profile.insuranceCompany
            }
            
        case .professional:
            if profile.profession.isEmpty && profile.company.isEmpty {
                return localStatusText("professional_info_not_provided")
            } else {
                let parts = [profile.profession, profile.company].filter { !$0.isEmpty }
                return parts.joined(separator: " • ")
            }
            
        case .preferences:
            let distanceUnitLocalized = localizeDistanceUnit(profile.distanceUnit)
            return "\(profile.preferredCurrency) • \(distanceUnitLocalized) • \(profile.language.uppercased())"
            
        case .financial:
            if profile.defaultVATRate > 0 {
                return "\(localStatusText("vat")) \(String(format: "%.0f", profile.defaultVATRate))% • \(localStatusText("budget")) \(String(format: "%.0f", profile.monthlyVehicleBudget))€"
            } else {
                return localStatusText("financial_settings_to_configure")
            }
        }
    }
    
    private func isCompletedSection(_ section: ProfileSection) -> Bool {
        switch section {
        case .personalInfo:
            return !profile.firstName.isEmpty && !profile.lastName.isEmpty && !profile.email.isEmpty
        case .address:
            return !profile.streetAddress.isEmpty && !profile.city.isEmpty && !profile.postalCode.isEmpty
        case .drivingLicense:
            return !profile.drivingLicenseNumber.isEmpty && profile.licenseExpirationDate != nil
        case .insurance:
            return !profile.insuranceCompany.isEmpty && !profile.insurancePolicyNumber.isEmpty
        case .professional:
            return true // Optionnel
        case .preferences:
            return true // Toujours configuré avec valeurs par défaut
        case .financial:
            return profile.defaultVATRate > 0
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return localStatusText("not_provided") }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: localizationService.currentLanguage == "en" ? "en_US" : "fr_FR")
        return formatter.string(from: date)
    }
}

#Preview {
    UserProfileView()
}