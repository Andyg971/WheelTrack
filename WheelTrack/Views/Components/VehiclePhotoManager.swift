import SwiftUI
import PhotosUI

// MARK: - Vehicle Photo Manager Component
struct VehiclePhotoManager: View {
    @Binding var vehicle: Vehicle
    @StateObject private var imageManager = ImageManager.shared
    @State private var showingPhotoPicker = false
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerType: PhotoPickerType = .main
    
    // MARK: - Types de sélecteur de photos
    private enum PhotoPickerType {
        case main
        case additional
        case documents
    }
    
    // États pour l'affichage
    @State private var mainImage: UIImage?
    @State private var additionalImages: [UIImage] = []
    @State private var documentImages: [UIImage] = []
    
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Photo principale
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Photo principale", systemImage: "camera")
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
                                Text("Ajouter une photo principale")
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
                    Label("Photos supplémentaires", systemImage: "photo.on.rectangle")
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
                    Text("Aucune photo supplémentaire")
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
                    Label("Documents", systemImage: "doc.fill")
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
                    Text("Aucun document")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding()
        .onAppear {
            loadExistingImages()
            imageManager.createDirectoriesIfNeeded()
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerCoordinator(
                selectedImages: $selectedImages,
                allowsMultipleSelection: photoPickerType != .main,
                maxSelectionCount: photoPickerType == .main ? 1 : 5
            )
        }
        .onChange(of: selectedImages) { _, newImages in
            handleSelectedImages(newImages)
        }
    }
    
    // MARK: - Méthodes privées
    private func handleSelectedImages(_ images: [UIImage]) {
        guard !images.isEmpty else { return }
        
        switch photoPickerType {
        case .main:
            if let image = images.first {
                saveMainImage(image)
            }
        case .additional:
            saveAdditionalImages(images)
        case .documents:
            saveDocumentImages(images)
        }
        
        selectedImages = []
    }
    
    private func saveMainImage(_ image: UIImage) {
        // Supprimer l'ancienne image principale si elle existe
        if let oldImageURL = vehicle.mainImageURL {
            _ = imageManager.deleteImage(fileName: oldImageURL, from: .vehicle)
        }
        
        // Compresser et sauvegarder la nouvelle image
        if let compressedImage = imageManager.compressImage(image, maxSizeKB: 800),
           let fileName = imageManager.saveImage(compressedImage, to: .vehicle) {
            vehicle.mainImageURL = fileName
            mainImage = compressedImage
        }
    }
    
    private func saveAdditionalImages(_ images: [UIImage]) {
        for image in images {
            if let compressedImage = imageManager.compressImage(image, maxSizeKB: 500),
               let fileName = imageManager.saveImage(compressedImage, to: .vehicle) {
                vehicle.additionalImagesURLs.append(fileName)
                additionalImages.append(compressedImage)
            }
        }
    }
    
    private func saveDocumentImages(_ images: [UIImage]) {
        for image in images {
            if let compressedImage = imageManager.compressImage(image, maxSizeKB: 800),
               let fileName = imageManager.saveImage(compressedImage, to: .vehicle) {
                vehicle.documentsImageURLs.append(fileName)
                documentImages.append(compressedImage)
            }
        }
    }
    
    private func deleteMainImage() {
        if let imageURL = vehicle.mainImageURL {
            _ = imageManager.deleteImage(fileName: imageURL, from: .vehicle)
            vehicle.mainImageURL = nil
            mainImage = nil
        }
    }
    
    private func deleteAdditionalImage(at index: Int) {
        guard index < vehicle.additionalImagesURLs.count else { return }
        
        let fileName = vehicle.additionalImagesURLs[index]
        _ = imageManager.deleteImage(fileName: fileName, from: .vehicle)
        
        vehicle.additionalImagesURLs.remove(at: index)
        additionalImages.remove(at: index)
    }
    
    private func deleteDocumentImage(at index: Int) {
        guard index < vehicle.documentsImageURLs.count else { return }
        
        let fileName = vehicle.documentsImageURLs[index]
        _ = imageManager.deleteImage(fileName: fileName, from: .vehicle)
        
        vehicle.documentsImageURLs.remove(at: index)
        documentImages.remove(at: index)
    }
    
    private func loadExistingImages() {
        // Charger la photo principale
        if let mainImageURL = vehicle.mainImageURL {
            mainImage = imageManager.loadImage(fileName: mainImageURL, from: .vehicle)
        }
        
        // Charger les photos supplémentaires
        additionalImages = vehicle.additionalImagesURLs.compactMap { fileName in
            imageManager.loadImage(fileName: fileName, from: .vehicle)
        }
        
        // Charger les documents
        documentImages = vehicle.documentsImageURLs.compactMap { fileName in
            imageManager.loadImage(fileName: fileName, from: .vehicle)
        }
    }
}

// MARK: - Preview
#Preview {
    VehiclePhotoManager(vehicle: .constant(Vehicle(
        brand: "BMW",
        model: "X3",
        year: 2023,
        licensePlate: "AB-123-CD",
        mileage: 15000,
        fuelType: .gasoline,
        transmission: .automatic,
        color: "Noir",
        purchaseDate: Date(),
        purchasePrice: 45000,
        purchaseMileage: 0
    )))
} 