//
//  AdultingApp.swift
//  Adulting
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI
import AVFoundation
import Firebase

@main
struct AdultingApp: App {
    // Initialize Firebase manager
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Request microphone permissions on app startup
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            print("Microphone permission granted: \(granted)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if firebaseManager.isSignedIn {
                // Check if user profile is complete
                if let profile = firebaseManager.userProfile, !profile.name.isEmpty {
                    // User is fully onboarded, show main content
                    ContentView()
                        .environmentObject(firebaseManager)
                        .onAppear {
                            // Set up audio session for the app
                            do {
                                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth])
                                try AVAudioSession.sharedInstance().setActive(true)
                            } catch {
                                print("Failed to set up audio session: \(error)")
                            }
                        }
                } else {
                    // User is authenticated but needs to complete onboarding
                    OnboardingView()
                        .environmentObject(firebaseManager)
                }
            } else {
                // User is not signed in, show sign-in view
                SignInView()
                    .environmentObject(firebaseManager)
            }
        }
    }
}
