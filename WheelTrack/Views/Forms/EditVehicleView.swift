import SwiftUI
import PhotosUI
import UIKit

struct EditVehicleView: View {
    var vehicle: Vehicle
    var onSave: (Vehicle) -> Void

    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_language") private var appLanguage = "fr"
    
    // Fonction de localisation
    static func localText(_ key: String, language: String) -> String {
        switch key {
        case "brand":
            return language == "en" ? "Brand" : "Marque"
        case "model":
            return language == "en" ? "Model" : "Modèle"
        case "year":
            return language == "en" ? "Year" : "Année"
        case "license_plate":
            return language == "en" ? "License Plate" : "Immatriculation"
        case "mileage":
            return language == "en" ? "Mileage" : "Kilométrage"
        case "fuel":
            return language == "en" ? "Fuel" : "Carburant"
        case "transmission":
            return language == "en" ? "Transmission" : "Transmission"
        case "color":
            return language == "en" ? "Color" : "Couleur"
        case "purchase_date":
            return language == "en" ? "Purchase Date" : "Date d'achat"
        case "purchase_price":
            return language == "en" ? "Purchase Price" : "Prix d'achat"
        case "purchase_mileage":
            return language == "en" ? "Purchase Mileage" : "Kilométrage à l'achat"
        case "active_vehicle":
            return language == "en" ? "Active Vehicle" : "Véhicule actif"
        case "inactive_note":
            return language == "en" ? "An inactive vehicle will not appear in statistics and will be marked with a gray dot" : "Un véhicule inactif n'apparaîtra pas dans les statistiques et sera marqué d'un point gris"
        case "edit_vehicle":
            return language == "en" ? "Edit Vehicle" : "Modifier véhicule"
        case "save":
            return language == "en" ? "Save" : "Enregistrer"
        case "cancel":
            return language == "en" ? "Cancel" : "Annuler"
        default:
            return key
        }
    }

    @State private var brand: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var licensePlate: String = ""
    @State private var mileage: String = ""
    @State private var fuelType: FuelType = .gasoline
    @State private var transmission: TransmissionType = .manual
    @State private var color: String = ""
    @State private var purchaseDate: Date = Date()
    @State private var purchasePrice: String = ""
    @State private var purchaseMileage: String = ""
    @State private var isActive: Bool = true
    @State private var editableVehicle: Vehicle = Vehicle(brand: "", model: "", year: 2024, licensePlate: "", mileage: 0, fuelType: .diesel, transmission: .manual, color: "", purchaseDate: Date(), purchasePrice: 0, purchaseMileage: 0)

    var body: some View {
        NavigationStack {
            Form {
                TextField(EditVehicleView.localText("brand", language: appLanguage), text: $brand)
                TextField(EditVehicleView.localText("model", language: appLanguage), text: $model)
                TextField(EditVehicleView.localText("year", language: appLanguage), text: $year)
                    .keyboardType(.numberPad)
                LicensePlateTextField(EditVehicleView.localText("license_plate", language: appLanguage), text: $licensePlate)
                TextField(EditVehicleView.localText("mileage", language: appLanguage), text: $mileage)
                    .keyboardType(.numberPad)
                Picker(EditVehicleView.localText("fuel", language: appLanguage), selection: $fuelType) {
                    ForEach(FuelType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                Picker(EditVehicleView.localText("transmission", language: appLanguage), selection: $transmission) {
                    ForEach(TransmissionType.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                TextField(EditVehicleView.localText("color", language: appLanguage), text: $color)
                DatePicker(EditVehicleView.localText("purchase_date", language: appLanguage), selection: $purchaseDate, displayedComponents: .date)
                .environment(\.locale, Locale(identifier: appLanguage == "fr" ? "fr_FR" : "en_US"))
                TextField(EditVehicleView.localText("purchase_price", language: appLanguage), text: $purchasePrice)
                    .keyboardType(.decimalPad)
                TextField(EditVehicleView.localText("purchase_mileage", language: appLanguage), text: $purchaseMileage)
                    .keyboardType(.numberPad)
                
                Section {
                    Toggle(EditVehicleView.localText("active_vehicle", language: appLanguage), isOn: $isActive)
                        .toggleStyle(SwitchToggleStyle(tint: .green))
                } footer: {
                    Text(EditVehicleView.localText("inactive_note", language: appLanguage))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                // MARK: - Section Photos
                Section {
                    VehiclePhotoEditSection(vehicle: $editableVehicle)
                } header: {
                    Text(appLanguage == "en" ? "Photos & Documents" : "Photos et Documents")
                } footer: {
                    Text(appLanguage == "en" ? "Manage photos of your vehicle and important documents" : "Gérez les photos de votre véhicule et les documents importants")
                }
            }
            .navigationTitle(EditVehicleView.localText("edit_vehicle", language: appLanguage))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(EditVehicleView.localText("save", language: appLanguage)) {
                        guard let yearInt = Int(year),
                              let mileageDouble = Double(mileage),
                              let purchasePriceDouble = Double(purchasePrice),
                              let purchaseMileageDouble = Double(purchaseMileage)
                        else { return }
                        var updatedVehicle = Vehicle(
                            id: vehicle.id,
                            brand: brand,
                            model: model,
                            year: yearInt,
                            licensePlate: licensePlate,
                            mileage: mileageDouble,
                            fuelType: fuelType,
                            transmission: transmission,
                            color: color,
                            purchaseDate: purchaseDate,
                            purchasePrice: purchasePriceDouble,
                            purchaseMileage: purchaseMileageDouble
                        )
                        
                        // Préserver les autres propriétés du véhicule original
                        updatedVehicle.isActive = isActive
                        updatedVehicle.isAvailableForRent = vehicle.isAvailableForRent
                        updatedVehicle.rentalPrice = vehicle.rentalPrice
                        updatedVehicle.depositAmount = vehicle.depositAmount
                        updatedVehicle.minimumRentalDays = vehicle.minimumRentalDays
                        updatedVehicle.maximumRentalDays = vehicle.maximumRentalDays
                        updatedVehicle.vehicleDescription = vehicle.vehicleDescription
                        updatedVehicle.privateNotes = vehicle.privateNotes
                        updatedVehicle.lastMaintenanceDate = vehicle.lastMaintenanceDate
                        updatedVehicle.nextMaintenanceDate = vehicle.nextMaintenanceDate
                        updatedVehicle.estimatedValue = vehicle.estimatedValue
                        updatedVehicle.resaleDate = vehicle.resaleDate
                        updatedVehicle.resalePrice = vehicle.resalePrice
                        
                        // Préserver les photos du véhicule éditable
                        updatedVehicle.mainImageURL = editableVehicle.mainImageURL
                        updatedVehicle.additionalImagesURLs = editableVehicle.additionalImagesURLs
                        updatedVehicle.documentsImageURLs = editableVehicle.documentsImageURLs
                        onSave(updatedVehicle)
                        dismiss()
                    }
                    .disabled(brand.isEmpty || model.isEmpty || year.isEmpty || licensePlate.isEmpty || mileage.isEmpty || color.isEmpty || purchasePrice.isEmpty || purchaseMileage.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(EditVehicleView.localText("cancel", language: appLanguage)) { dismiss() }
                }
            }
            .onAppear {
                brand = vehicle.brand
                model = vehicle.model
                year = String(vehicle.year)
                licensePlate = vehicle.licensePlate
                mileage = String(vehicle.mileage)
                fuelType = vehicle.fuelType
                transmission = vehicle.transmission
                color = vehicle.color
                purchaseDate = vehicle.purchaseDate
                purchasePrice = String(vehicle.purchasePrice)
                purchaseMileage = String(vehicle.purchaseMileage)
                isActive = vehicle.isActive
                
                // Initialiser editableVehicle avec le véhicule actuel
                editableVehicle = vehicle
            }
        }
    }
}

// MARK: - Vehicle Photo Edit Section (Version pour édition)
struct VehiclePhotoEditSection: View {
    @Binding var vehicle: Vehicle
    @State private var imageManager = VehicleImageManager()
    @State private var showingPhotoPicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerType: PhotoPickerType = .main
    @AppStorage("app_language") private var appLanguage = "fr"
    
    // États pour l'affichage
    @State private var mainImage: UIImage?
    @State private var additionalImages: [UIImage] = []
    @State private var documentImages: [UIImage] = []
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Photo principale
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(appLanguage == "en" ? "Main Photo" : "Photo principale", systemImage: "camera")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        photoPickerType = .main
                        showingPhotoPicker = true
                    }) {
                        Image(systemName: mainImage == nil ? "plus.circle.fill" : "pencil.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                // Affichage de la photo principale
                if let mainImage = mainImage {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: mainImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(12)
                        
                        Button(action: deleteMainImage) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .background(Color.white, in: Circle())
                                .font(.title2)
                        }
                        .padding(8)
                    }
                } else {
                    // Placeholder pour photo principale
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(height: 200)
                        .overlay(
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text(appLanguage == "en" ? "Add main photo" : "Ajouter une photo principale")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        )
                        .onTapGesture {
                            photoPickerType = .main
                            showingPhotoPicker = true
                        }
                }
            }
            
            // MARK: - Photos supplémentaires
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(appLanguage == "en" ? "Additional Photos" : "Photos supplémentaires", systemImage: "photo.on.rectangle")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        photoPickerType = .additional
                        showingPhotoPicker = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                if !additionalImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(additionalImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 90)
                                        .clipped()
                                        .cornerRadius(8)
                                    
                                    Button(action: { deleteAdditionalImage(at: index) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .background(Color.white, in: Circle())
                                            .font(.caption)
                                    }
                                    .padding(4)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Text(appLanguage == "en" ? "No additional photos" : "Aucune photo supplémentaire")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                }
            }
            
            // MARK: - Documents
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label(appLanguage == "en" ? "Documents" : "Documents", systemImage: "doc.fill")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        photoPickerType = .documents
                        showingPhotoPicker = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                if !documentImages.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(documentImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 90)
                                        .clipped()
                                        .cornerRadius(8)
                                    
                                    Button(action: { deleteDocumentImage(at: index) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .background(Color.white, in: Circle())
                                            .font(.caption)
                                    }
                                    .padding(4)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    Text(appLanguage == "en" ? "No documents" : "Aucun document")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .onAppear {
            loadExistingImages()
            imageManager.createDirectoriesIfNeeded()
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerWrapper(
                selectedImages: $selectedImages,
                allowsMultipleSelection: photoPickerType != .main,
                maxSelectionCount: photoPickerType == .main ? 1 : 5
            )
        }
        .onChange(of: selectedImages) { _, newImages in
            handleSelectedImages(newImages)
        }
    }
    
    // MARK: - Fonctions de gestion des images
    private func loadExistingImages() {
        if let mainImageURL = vehicle.mainImageURL {
            mainImage = imageManager.loadImage(fileName: mainImageURL)
        }
        
        additionalImages = vehicle.additionalImagesURLs.compactMap { fileName in
            imageManager.loadImage(fileName: fileName)
        }
        
        documentImages = vehicle.documentsImageURLs.compactMap { fileName in
            imageManager.loadImage(fileName: fileName)
        }
    }
    
    private func handleSelectedImages(_ images: [UIImage]) {
        guard !images.isEmpty else { return }
        
        switch photoPickerType {
        case .main:
            if let image = images.first {
                mainImage = imageManager.compressImage(image, maxSizeKB: 800)
                // Sauvegarder et mettre à jour le véhicule
                if let fileName = imageManager.saveImage(image) {
                    vehicle.mainImageURL = fileName
                }
            }
            
        case .additional:
            for image in images {
                if let compressedImage = imageManager.compressImage(image, maxSizeKB: 500) {
                    additionalImages.append(compressedImage)
                    // Sauvegarder et mettre à jour le véhicule
                    if let fileName = imageManager.saveImage(compressedImage) {
                        vehicle.additionalImagesURLs.append(fileName)
                    }
                }
            }
            
        case .documents:
            for image in images {
                if let compressedImage = imageManager.compressImage(image, maxSizeKB: 500) {
                    documentImages.append(compressedImage)
                    // Sauvegarder et mettre à jour le véhicule
                    if let fileName = imageManager.saveImage(compressedImage) {
                        vehicle.documentsImageURLs.append(fileName)
                    }
                }
            }
        }
        
        selectedImages = []
    }
    
    private func deleteMainImage() {
        if let imageURL = vehicle.mainImageURL {
            let _ = imageManager.deleteImage(fileName: imageURL)
        }
        mainImage = nil
        vehicle.mainImageURL = nil
    }
    
    private func deleteAdditionalImage(at index: Int) {
        guard index < vehicle.additionalImagesURLs.count else { return }
        
        let fileName = vehicle.additionalImagesURLs[index]
        let _ = imageManager.deleteImage(fileName: fileName)
        
        additionalImages.remove(at: index)
        vehicle.additionalImagesURLs.remove(at: index)
    }
    
    private func deleteDocumentImage(at index: Int) {
        guard index < vehicle.documentsImageURLs.count else { return }
        
        let fileName = vehicle.documentsImageURLs[index]
        let _ = imageManager.deleteImage(fileName: fileName)
        
        documentImages.remove(at: index)
        vehicle.documentsImageURLs.remove(at: index)
    }
}

#Preview {
    EditVehicleView(vehicle: Vehicle(brand: "Toyota", model: "Corolla", year: 2020, licensePlate: "AB-123-CD", mileage: 50000, fuelType: .diesel, transmission: .manual, color: "Gris", purchaseDate: Date(), purchasePrice: 18000, purchaseMileage: 0)) { _ in }
} 