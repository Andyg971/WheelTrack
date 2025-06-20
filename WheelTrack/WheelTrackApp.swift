//
//  WheelTrackApp.swift
//  WheelTrack
//
//  Created by Grava Andy on 17/03/2025.
//

import SwiftUI

@main
struct WheelTrackApp: App {
    @StateObject private var localizationService = LocalizationService.shared
    @StateObject private var appleSignInService = AppleSignInService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(localizationService)
                .environmentObject(appleSignInService)
                .onAppear {
                    // Charger l'état de connexion persisté au démarrage
                    appleSignInService.loadUserIdentifier()
                }
        }
    }
}
