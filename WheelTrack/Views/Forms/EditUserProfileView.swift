import SwiftUI
import PhotosUI

struct EditUserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var profileService = UserProfileService.shared
    
    @State private var profile: UserProfile
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    
    init() {
        _profile = State(initialValue: UserProfileService.shared.userProfile)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Section photo de profil
                Section {
                    profileImageSection
                } header: {
                    Text(L(CommonTranslations.profilePhoto))
                }
                
                // Informations personnelles
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
                } header: {
                    Text(L(CommonTranslations.personalInformation))
                } footer: {
                    Text("Ces informations sont utilisées pour vos documents et assurances")
                }
                
                // Adresse
                Section {
                    TextField("Adresse", text: $profile.streetAddress)
                    TextField("Ville", text: $profile.city)
                    TextField("Code postal", text: $profile.postalCode)
                        .keyboardType(.numberPad)
                    TextField("Pays", text: $profile.country)
                } header: {
                    Text("Adresse de domicile")
                } footer: {
                    Text("Utilisée pour localiser les garages les plus proches")
                }
            }
            .navigationTitle(L(CommonTranslations.editProfile))
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
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let newItem = newItem {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        profile.profileImageData = data
                    }
                }
            }
        }
    }    
    // MARK: - Section photo de profil
    private var profileImageSection: some View {
        HStack {
            Spacer()
            
            VStack(spacing: 16) {
                // Photo actuelle ou placeholder
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    if let imageData = profile.profileImageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    // Bouton d'édition
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            
                            PhotosPicker(
                                selection: $selectedPhotoItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 32, height: 32)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                }
                
                // Boutons d'action
                HStack(spacing: 16) {
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label("Choisir", systemImage: "photo.fill")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .buttonStyle(.bordered)
                    
                    if profile.profileImageData != nil {
                        Button {
                            profile.profileImageData = nil
                        } label: {
                            Label("Supprimer", systemImage: "trash.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    EditUserProfileView()
}