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
    // @StateObject private var tutorialService = TutorialService.shared // Temporairement commenté
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(localizationService)
                // .fullScreenCover(isPresented: $tutorialService.shouldShowTutorial) {
                //     TutorialView {
                //         // Callback quand le tutoriel se termine
                //         tutorialService.completeTutorial()
                //     }
                //     .environmentObject(localizationService)
                // }
        }
    }
}
