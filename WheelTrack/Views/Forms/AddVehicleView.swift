import SwiftUI

/// Champ de saisie spécialisé pour les plaques d'immatriculation françaises
/// Accepte uniquement : lettres majuscules (A-Z), chiffres (0-9) et caractères spéciaux autorisés
struct LicensePlateTextField: View {
    @Binding var text: String
    let placeholder: String
    
    /// Caractères autorisés pour une plaque d'immatriculation française
    private let allowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789- ")
    
    /// Longueur maximale d'une plaque d'immatriculation (avec espaces et tirets)
    private let maxLength = 10
    
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 16, weight: .medium, design: .monospaced))
            .textCase(.uppercase)
            .autocorrectionDisabled()
            .textInputAutocapitalization(.characters)
            .onChange(of: text) { oldValue, newValue in
                filterAndFormatInput(newValue)
            }
    }
    
    /// Filtre et formate l'entrée utilisateur en temps réel
    private func filterAndFormatInput(_ newValue: String) {
        // Convertir en majuscules
        let uppercased = newValue.uppercased()
        
        // Filtrer les caractères non autorisés
        let filtered = String(uppercased.unicodeScalars.filter { scalar in
            allowedCharacters.contains(scalar)
        })
        
        // Limiter la longueur
        let limited = String(filtered.prefix(maxLength))
        
        // Mettre à jour seulement si différent pour éviter les boucles
        if limited != text {
            DispatchQueue.main.async {
                self.text = limited
            }
        }
    }
}

struct AddVehicleView: View {
    var onAdd: (Vehicle) -> Void
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_language") private var appLanguage = "fr"
    
    // Fonction de localisation
    static func localText(_ key: String, language: String) -> String {
        switch key {
        case "new_vehicle":
            return language == "en" ? "New Vehicle" : "Nouveau véhicule"
        case "brand":
            return language == "en" ? "Brand" : "Marque"
        case "model":
            return language == "en" ? "Model" : "Modèle"
        case "year":
            return language == "en" ? "Year" : "Année"
        case "mileage":
            return language == "en" ? "Mileage" : "Kilométrage"
        case "license_plate":
            return language == "en" ? "License Plate" : "Plaque d'immatriculation"
        case "fuel_type":
            return language == "en" ? "Fuel Type" : "Type de carburant"
        case "transmission":
            return language == "en" ? "Transmission" : "Transmission"
        case "color":
            return language == "en" ? "Color" : "Couleur"
        case "vehicle_info":
            return language == "en" ? "Vehicle Information" : "Informations du véhicule"
        case "available_for_rent":
            return language == "en" ? "Available for rent" : "Disponible pour location"
        case "rental_service":
            return language == "en" ? "Service > Rental" : "Service > Location"
        case "daily_rate":
            return language == "en" ? "Daily rate (€)" : "Tarif par jour (€)"
        case "deposit":
            return language == "en" ? "Deposit (€)" : "Caution (€)"
        case "rental_config":
            return language == "en" ? "Basic rental rates configuration for this vehicle." : "Configuration des tarifs de base pour la location de ce véhicule."
        case "duration_settings":
            return language == "en" ? "Duration Settings" : "Paramètres de durée"
        case "minimum_duration":
            return language == "en" ? "Minimum duration" : "Durée minimum"
        case "maximum_duration":
            return language == "en" ? "Maximum duration" : "Durée maximum"
        case "days":
            return language == "en" ? "Days" : "Jours"
        case "days_suffix":
            return language == "en" ? "day(s)" : "jour(s)"
        case "duration_config":
            return language == "en" ? "Set minimum and maximum durations for rentals." : "Définissez les durées minimum et maximum pour les locations."
        case "renter_description":
            return language == "en" ? "Description for renters" : "Description pour les locataires"
        case "vehicle_description_placeholder":
            return language == "en" ? "Describe equipment, vehicle features..." : "Décrivez les équipements, particularités du véhicule..."
        case "private_notes":
            return language == "en" ? "Private Notes" : "Notes privées"
        case "private_notes_placeholder":
            return language == "en" ? "Private notes (not visible to renters)" : "Notes privées (non visibles par les locataires)"
        case "add":
            return language == "en" ? "Add" : "Ajouter"
        case "cancel":
            return language == "en" ? "Cancel" : "Annuler"
        default:
            return key
        }
    }
    @State private var brand = ""
    @State private var model = ""
    @State private var year = ""
    @State private var mileage = ""
    @State private var fuelType: FuelType = .diesel
    @State private var licensePlate = ""
    @State private var transmission: TransmissionType = .manual
    @State private var color = ""
    @State private var notes = ""
    
    // Champs pour la location
    @State private var isAvailableForRent = true
    @State private var rentalPricePerDay = ""
    @State private var depositAmount = ""
    @State private var minimumRentalDays = "1"
    @State private var maximumRentalDays = "30"
    @State private var vehicleDescription = ""
    
    // Service de location pour créer les contrats préremplis
    private var rentalService: RentalService { RentalService.shared }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField(AddVehicleView.localText("brand", language: appLanguage), text: $brand)
                    TextField(AddVehicleView.localText("model", language: appLanguage), text: $model)
                    TextField(AddVehicleView.localText("year", language: appLanguage), text: $year)
                        .keyboardType(.numberPad)
                    TextField(AddVehicleView.localText("mileage", language: appLanguage), text: $mileage)
                        .keyboardType(.numberPad)
                    LicensePlateTextField(AddVehicleView.localText("license_plate", language: appLanguage), text: $licensePlate)
                    
                    Picker(AddVehicleView.localText("fuel_type", language: appLanguage), selection: $fuelType) {
                        ForEach(FuelType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    Picker(AddVehicleView.localText("transmission", language: appLanguage), selection: $transmission) {
                        ForEach(TransmissionType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField(AddVehicleView.localText("color", language: appLanguage), text: $color)
                } header: {
                    Text(AddVehicleView.localText("vehicle_info", language: appLanguage))
                }
                
                Section {
                    Toggle(AddVehicleView.localText("available_for_rent", language: appLanguage), isOn: $isAvailableForRent)
                    
                    if isAvailableForRent {
                        TextField(AddVehicleView.localText("daily_rate", language: appLanguage), text: $rentalPricePerDay)
                            .keyboardType(.decimalPad)
                        
                        TextField(AddVehicleView.localText("deposit", language: appLanguage), text: $depositAmount)
                            .keyboardType(.decimalPad)
                    }
                } header: {
                    Text(AddVehicleView.localText("rental_service", language: appLanguage))
                } footer: {
                    if isAvailableForRent {
                        Text(AddVehicleView.localText("rental_config", language: appLanguage))
                    }
                }
                
                Section {
                    HStack {
                        Text(AddVehicleView.localText("minimum_duration", language: appLanguage))
                        Spacer()
                        TextField(AddVehicleView.localText("days", language: appLanguage), text: $minimumRentalDays)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .disabled(!isAvailableForRent)
                        Text(AddVehicleView.localText("days_suffix", language: appLanguage))
                    }
                    
                    HStack {
                        Text(AddVehicleView.localText("maximum_duration", language: appLanguage))
                        Spacer()
                        TextField(AddVehicleView.localText("days", language: appLanguage), text: $maximumRentalDays)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .disabled(!isAvailableForRent)
                        Text(AddVehicleView.localText("days_suffix", language: appLanguage))
                    }
                } header: {
                    Text(AddVehicleView.localText("duration_settings", language: appLanguage))
                } footer: {
                    if isAvailableForRent {
                        Text(AddVehicleView.localText("duration_config", language: appLanguage))
                    }
                }
                
                Section {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $vehicleDescription)
                            .frame(height: 80)
                        
                        if vehicleDescription.isEmpty {
                            Text(AddVehicleView.localText("vehicle_description_placeholder", language: appLanguage))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                        }
                    }
                } header: {
                    Text(AddVehicleView.localText("renter_description", language: appLanguage))
                }
                
                Section {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $notes)
                            .frame(height: 60)
                        
                        if notes.isEmpty {
                            Text(AddVehicleView.localText("private_notes_placeholder", language: appLanguage))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                        }
                    }
                } header: {
                    Text(AddVehicleView.localText("private_notes", language: appLanguage))
                }
            }
            .navigationTitle(AddVehicleView.localText("new_vehicle", language: appLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AddVehicleView.localText("cancel", language: appLanguage)) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(AddVehicleView.localText("add", language: appLanguage)) {
                        saveVehicle()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !brand.isEmpty && !model.isEmpty && !year.isEmpty && 
        !mileage.isEmpty && !licensePlate.isEmpty && 
        (!isAvailableForRent || !rentalPricePerDay.isEmpty)
    }
    
    private func saveVehicle() {
        guard let yearInt = Int(year),
              let mileageDouble = Double(mileage) else {
            return
        }
        
        // Valeurs par défaut pour les champs d'achat (requis par le modèle actuel)
        let defaultPurchaseDate = Date()
        let defaultPurchasePrice = 0.0
        
        let vehicle = Vehicle(
            brand: brand,
            model: model,
            year: yearInt,
            licensePlate: licensePlate,
            mileage: mileageDouble,
            fuelType: fuelType,
            transmission: transmission,
            color: color,
            purchaseDate: defaultPurchaseDate, // Valeur par défaut
            purchasePrice: defaultPurchasePrice, // Valeur par défaut
            purchaseMileage: mileageDouble
        )
        
        // Mise à jour des champs de location
        var updatedVehicle = vehicle
        updatedVehicle.isAvailableForRent = isAvailableForRent
        updatedVehicle.rentalPrice = Double(rentalPricePerDay)
        updatedVehicle.depositAmount = Double(depositAmount)
        updatedVehicle.minimumRentalDays = Int(minimumRentalDays)
        updatedVehicle.maximumRentalDays = Int(maximumRentalDays)
        updatedVehicle.vehicleDescription = vehicleDescription.isEmpty ? nil : vehicleDescription
        updatedVehicle.privateNotes = notes.isEmpty ? nil : notes
        
        // Ajouter le véhicule d'abord
        onAdd(updatedVehicle)
        
        // Si le véhicule est disponible pour location, créer automatiquement un contrat prérempli
        if isAvailableForRent && Double(rentalPricePerDay) != nil && Double(rentalPricePerDay)! > 0 {
            // ✅ Exécution immédiate pour une meilleure réactivité
            rentalService.autoCreatePrefilledContract(for: updatedVehicle)
        }
        
        dismiss()
    }
}



#Preview {
    AddVehicleView { _ in }
} 