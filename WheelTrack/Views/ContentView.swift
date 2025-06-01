import SwiftUI

struct ContentView: View {
    @ObservedObject private var signInService = AppleSignInService.shared
    @StateObject private var vehiclesViewModel = VehiclesViewModel()
    @StateObject private var expensesViewModel = ExpensesViewModel()
    @StateObject private var maintenanceViewModel = MaintenanceViewModel()
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                // Écran de chargement pour éviter le flash de WelcomeView
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        // Logo ou icône de l'app
                        Image(systemName: "car.2.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.blue)
                        
                        Text("WheelTrack")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        ProgressView()
                            .scaleEffect(1.2)
                    }
                }
            } else if signInService.userIdentifier != nil {
                TabView {
                    DashboardView(viewModel: expensesViewModel, vehiclesViewModel: vehiclesViewModel)
                        .tabItem {
                            Label("Tableau de bord", systemImage: "chart.bar.fill")
                        }
                    VehiclesView(viewModel: vehiclesViewModel, expensesViewModel: expensesViewModel, maintenanceViewModel: maintenanceViewModel)
                        .tabItem {
                            Label("Véhicules", systemImage: "car.fill")
                        }
                    MaintenanceView(vehicles: vehiclesViewModel.vehicles, viewModel: maintenanceViewModel)
                        .tabItem {
                            Label("Maintenance", systemImage: "wrench.fill")
                        }
                    ExpensesView(viewModel: expensesViewModel, vehiclesViewModel: vehiclesViewModel)
                        .tabItem {
                            Label("Dépenses", systemImage: "dollarsign.circle.fill")
                        }
                    GaragesView()
                        .tabItem {
                            Label("Garages", systemImage: "building.2.fill")
                        }
                    SettingsView()
                        .tabItem {
                            Label("Réglages", systemImage: "gear")
                        }
                }
                .onAppear {
                    // Configuration de la synchronisation bidirectionnelle
                    expensesViewModel.configure(with: maintenanceViewModel, vehiclesViewModel: vehiclesViewModel)
                    maintenanceViewModel.configure(with: expensesViewModel, vehiclesViewModel: vehiclesViewModel)
                }
            } else {
                WelcomeView()
            }
        }
        .onAppear {
            // Vérifier immédiatement l'état de connexion
            checkAuthenticationState()
        }
    }
    
    /// Vérifie l'état d'authentification de manière optimisée
    private func checkAuthenticationState() {
        // Si l'utilisateur est déjà identifié, on peut raccourcir le délai
        if signInService.userIdentifier != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isLoading = false
                }
            }
        } else {
            // Délai un peu plus long pour vérifier si l'utilisateur se connecte
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
} 
