import SwiftUI
import PhotosUI
import UIKit

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
    var currentVehicleCount: Int = 0 // ✅ Nouveau paramètre pour compter les véhicules existants
    var onAdd: (Vehicle) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_language") private var appLanguage = "fr"
    @StateObject private var freemiumService = FreemiumService.shared
    
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
        case "validation_error":
            return language == "en" ? "Validation Error" : "Erreur de validation"
        case "ok":
            return language == "en" ? "OK" : "OK"
        case "required_fields":
            return language == "en" ? "is required" : "est obligatoire"
        case "invalid_year":
            return language == "en" ? "Year must be between 1900 and 2030" : "L'année doit être entre 1900 et 2030"
        case "invalid_mileage":
            return language == "en" ? "Mileage must be positive" : "Le kilométrage doit être positif"
        case "invalid_price":
            return language == "en" ? "Price must be greater than 0" : "Le prix doit être supérieur à 0"
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
    
    // États de validation
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    // État pour la gestion des photos
    @State private var newVehicle = Vehicle(
        brand: "",
        model: "",
        year: 2024,
        licensePlate: "",
        mileage: 0,
        fuelType: .diesel,
        transmission: .manual,
        color: "",
        purchaseDate: Date(),
        purchasePrice: 0,
        purchaseMileage: 0
    )
    
    // Service de location pour créer les contrats préremplis
    private var rentalService: RentalService { RentalService.shared }
    
    var body: some View {
        NavigationView {
            Form {
                // ✅ Section d'information freemium - limite atteinte
                if !freemiumService.isPremium && currentVehicleCount >= freemiumService.maxVehiclesFree {
                    Section {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Limite atteinte")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                            
                            Text("Vous avez atteint la limite de \(freemiumService.maxVehiclesFree) véhicules de la version gratuite. Passez à Premium pour ajouter des véhicules illimités.")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                            
                            Button(action: {
                                freemiumService.requestUpgrade(for: .unlimitedVehicles)
                            }) {
                                HStack {
                                    Image(systemName: "crown.fill")
                                    Text("Passer à Premium")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // ✅ Section d'information pour utilisateurs freemium proches de la limite
                if !freemiumService.isPremium && currentVehicleCount < freemiumService.maxVehiclesFree {
                    Section {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Version gratuite")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(currentVehicleCount + 1)/\(freemiumService.maxVehiclesFree) véhicules")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Button("Premium") {
                                freemiumService.requestUpgrade(for: .unlimitedVehicles)
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
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
                
                // MARK: - Section Photos
                Section {
                    VehiclePhotoSection(vehicle: $newVehicle)
                } header: {
                    Text(appLanguage == "en" ? "Photo" : "Photo")
                } footer: {
                    Text(appLanguage == "en" ? "Add a photo of your vehicle" : "Ajoutez une photo de votre véhicule")
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
                        // ✅ Vérification freemium AVANT la validation du formulaire
                        if !freemiumService.canAddVehicle(currentCount: currentVehicleCount) {
                            freemiumService.requestUpgrade(for: .unlimitedVehicles)
                            return
                        }
                        
                        if validateForm() {
                            saveVehicle()
                        } else {
                            showingValidationAlert = true
                        }
                    }
                }
            }
        }
        .alert(AddVehicleView.localText("validation_error", language: appLanguage), isPresented: $showingValidationAlert) {
            Button(AddVehicleView.localText("ok", language: appLanguage)) { }
        } message: {
            Text(validationMessage)
        }
        // ✅ Ajout de l'affichage premium
        .sheet(isPresented: $freemiumService.showUpgradeAlert) {
            if let blockedFeature = freemiumService.blockedFeature {
                PremiumUpgradeAlert(feature: blockedFeature)
                    .onAppear {
                        print("📱 AddVehicleView - Popup Premium affichée pour: \(blockedFeature)")
                    }
            }
        }
    }
    
    // MARK: - Validation
    
    /// Valide le formulaire et définit le message d'erreur approprié
    private func validateForm() -> Bool {
        // Vérifier les champs obligatoires
        if brand.trimmingCharacters(in: .whitespaces).isEmpty {
            validationMessage = AddVehicleView.localText("brand", language: appLanguage) + " " + AddVehicleView.localText("required_fields", language: appLanguage)
            return false
        }
        
        if model.trimmingCharacters(in: .whitespaces).isEmpty {
            validationMessage = AddVehicleView.localText("model", language: appLanguage) + " " + AddVehicleView.localText("required_fields", language: appLanguage)
            return false
        }
        
        if licensePlate.trimmingCharacters(in: .whitespaces).isEmpty {
            validationMessage = AddVehicleView.localText("license_plate", language: appLanguage) + " " + AddVehicleView.localText("required_fields", language: appLanguage)
            return false
        }
        
        // Valider l'année
        guard let yearInt = Int(year) else {
            validationMessage = AddVehicleView.localText("invalid_year", language: appLanguage)
            return false
        }
        
        if yearInt < 1900 || yearInt > 2030 {
            validationMessage = AddVehicleView.localText("invalid_year", language: appLanguage)
            return false
        }
        
        // Valider le kilométrage
        guard let mileageDouble = Double(mileage) else {
            validationMessage = AddVehicleView.localText("invalid_mileage", language: appLanguage)
            return false
        }
        
        if mileageDouble < 0 {
            validationMessage = AddVehicleView.localText("invalid_mileage", language: appLanguage)
            return false
        }
        
        // Valider les champs de location si activés
        if isAvailableForRent {
            if rentalPricePerDay.isEmpty {
                validationMessage = AddVehicleView.localText("daily_rate", language: appLanguage) + " " + AddVehicleView.localText("required_fields", language: appLanguage)
                return false
            }
            
            guard let priceDouble = Double(rentalPricePerDay) else {
                validationMessage = AddVehicleView.localText("invalid_price", language: appLanguage)
                return false
            }
            
            if priceDouble <= 0 {
                validationMessage = AddVehicleView.localText("invalid_price", language: appLanguage)
                return false
            }
        }
        
        return true
    }
    
    private func saveVehicle() {
        guard let yearInt = Int(year),
              let mileageDouble = Double(mileage) else {
            return
        }
        
        // Mettre à jour newVehicle avec les données du formulaire
        newVehicle.brand = brand
        newVehicle.model = model
        newVehicle.year = yearInt
        newVehicle.licensePlate = licensePlate
        newVehicle.mileage = mileageDouble
        newVehicle.fuelType = fuelType
        newVehicle.transmission = transmission
        newVehicle.color = color
        newVehicle.purchaseDate = Date()
        newVehicle.purchasePrice = 0.0
        newVehicle.purchaseMileage = mileageDouble
        
        // Mise à jour des champs de location
        newVehicle.isAvailableForRent = isAvailableForRent
        newVehicle.rentalPrice = Double(rentalPricePerDay)
        newVehicle.depositAmount = Double(depositAmount)
        newVehicle.minimumRentalDays = Int(minimumRentalDays)
        newVehicle.maximumRentalDays = Int(maximumRentalDays)
        newVehicle.vehicleDescription = vehicleDescription.isEmpty ? nil : vehicleDescription
        newVehicle.privateNotes = notes.isEmpty ? nil : notes
        
        // Ajouter le véhicule avec ses photos
        onAdd(newVehicle)
        
        // Si le véhicule est disponible pour location, créer automatiquement un contrat prérempli
        if isAvailableForRent && Double(rentalPricePerDay) != nil && Double(rentalPricePerDay)! > 0 {
            // ✅ Exécution immédiate pour une meilleure réactivité
            rentalService.autoCreatePrefilledContract(for: newVehicle)
        }
        
        dismiss()
    }
}

// MARK: - Photo Picker Type (DOIT être défini AVANT VehiclePhotoSection)
enum PhotoPickerType {
    case main
    case additional
    case documents
}

// MARK: - Vehicle Photo Section (ULTRA-SIMPLIFIÉ - Photo uniquement)
struct VehiclePhotoSection: View {
    @Binding var vehicle: Vehicle
    private let imageManager = ImageManager.shared
    @State private var showingPhotoPicker = false
    @AppStorage("app_language") private var appLanguage = "fr"
    
    // État pour l'affichage (1 seule photo)
    @State private var mainImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(appLanguage == "en" ? "Photo" : "Photo", systemImage: "camera")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    showingPhotoPicker = true
                }) {
                    Image(systemName: mainImage == nil ? "plus.circle.fill" : "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            if let mainImage = mainImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: mainImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                    
                    Button(action: deletePhoto) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .background(Color.white, in: Circle())
                            .font(.title2)
                    }
                    .padding(8)
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text(appLanguage == "en" ? "Add photo" : "Ajouter une photo")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
                    .onTapGesture {
                        showingPhotoPicker = true
                    }
            }
        }
        .onAppear {
            loadExistingImages()
            imageManager.createDirectoriesIfNeeded()
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerWrapper(
                allowsMultipleSelection: false,
                maxSelectionCount: 1
            ) { images in
                handlePhoto(images)
            }
        }
    }
    
    // MARK: - Fonctions
    private func loadExistingImages() {
        if let mainImageURL = vehicle.mainImageURL {
            mainImage = imageManager.loadImage(fileName: mainImageURL, from: .vehicleMainPhoto)
        }
    }
    
    private func handlePhoto(_ images: [UIImage]) {
        guard let image = images.first else { return }
        
        // Supprimer l'ancienne photo si elle existe
        if let oldImageURL = vehicle.mainImageURL {
            _ = imageManager.deleteImage(fileName: oldImageURL, from: .vehicleMainPhoto)
        }
        
        // Sauvegarder la nouvelle photo
        if let compressedImage = imageManager.compressImage(image, maxSizeKB: 800),
           let fileName = imageManager.saveImage(compressedImage, to: .vehicleMainPhoto) {
            vehicle.mainImageURL = fileName
            mainImage = compressedImage
        }
    }
    
    private func deletePhoto() {
        if let imageURL = vehicle.mainImageURL {
            _ = imageManager.deleteImage(fileName: imageURL, from: .vehicleMainPhoto)
        }
        mainImage = nil
        vehicle.mainImageURL = nil
    }
}

// MARK: - Photo Picker Wrapper
struct PhotoPickerWrapper: UIViewControllerRepresentable {
    let allowsMultipleSelection: Bool
    let maxSelectionCount: Int
    let onPicked: ([UIImage]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = allowsMultipleSelection ? maxSelectionCount : 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerWrapper
        
        init(_ parent: PhotoPickerWrapper) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.dismiss()
            
            guard !results.isEmpty else { return }
            
            var images: [UIImage] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let uiImage = image as? UIImage {
                        DispatchQueue.main.async {
                            images.append(uiImage)
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.parent.onPicked(images)
            }
        }
    }
}

// La classe VehicleImageManager a été supprimée.
// Utiliser ImageManager.shared à la place pour une gestion cohérente des dossiers.

#Preview("Freemium - 1/2 véhicules") {
    AddVehicleView(currentVehicleCount: 1) { _ in }
}

#Preview("Freemium - Limite atteinte") {
    AddVehicleView(currentVehicleCount: 2) { _ in }
} 
