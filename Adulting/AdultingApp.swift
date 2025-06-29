//
//  AdultingApp.swift
//  Adulting
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI
import AVFoundation
import Firebase
import GoogleSignIn
import PostHog

@main
struct AdultingApp: App {
    // Initialize Firebase manager
    @StateObject private var firebaseManager = FirebaseManager.shared
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
        
        // Configure Google Sign-In
        GoogleAuthenticator.configure()

        // Initialize PostHog analytics and session replay
        PostHogManager.shared.setup()
        
        // Request microphone permissions on app startup
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            print("Microphone permission granted: \(granted)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if firebaseManager.isSignedIn {
                    // Check if user profile is complete
                    if isOnboardingComplete() {
                        // User is fully onboarded, show main content
                        ContentView()
                            .environmentObject(firebaseManager)
                            .onAppear {
                                // Track main content view screen
                                PostHogManager.shared.trackScreen("ContentView")
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
                            .onAppear {
                                // Track onboarding view screen
                                PostHogManager.shared.trackScreen("OnboardingView")
                            }
                    }
                } else {
                    // User is not signed in, show sign-in view
                    SignInView()
                        .environmentObject(firebaseManager)
                        .onAppear {
                            // Track sign-in view screen
                            PostHogManager.shared.trackScreen("SignInView")
                        }
                }
            }
            .onOpenURL { url in
                GoogleAuthenticator.handleURL(url)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func isOnboardingComplete() -> Bool {
        guard let profile = firebaseManager.userProfile else { return false }
        
        return !profile.name.isEmpty &&
               !profile.email.isEmpty &&
               !profile.phoneNumber.isEmpty &&
               !profile.morningCallTime.isEmpty &&
               !profile.eveningCallTime.isEmpty
    }
}
