//
//  VapiManager.swift
//  Adulting
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI
import Combine
import AVFoundation
import Vapi

class VapiManager: ObservableObject {
    static let shared = VapiManager()
    
    // Vapi instance
    private var vapi: Vapi?
    private var cancellables = Set<AnyCancellable>()
    
    // UI state
    @Published var isCallActive = false
    @Published var isUserSpeaking = false
    @Published var isAssistantSpeaking = false
    @Published var isConnecting = false
    @Published var isReady = false
    
    // Replace with your actual Vapi API key
    private let apiKey = "3e24a7be-8ab7-49fa-8fe5-1ea466dbd9d8"
    
    // Assistant configuration
    private let assistantId = "be6f23c3-6a99-46f1-8ae6-48b92bfbcb27"
    
    private init() {
        setupVapiInstance()
    }
    
    private func setupVapiInstance() {
        // Create Vapi instance
        vapi = Vapi(publicKey: apiKey)
        
        // Set up event subscriptions
        setupEventPublisher()
    }
    
    // Ensure audio session remains active
    private func activateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to activate audio session: \(error.localizedDescription)")
        }
    }
    
    func startCall() {
        guard !isCallActive else { return }
        
        isReady = false
        isConnecting = true
        
        // Prevent screen from sleeping
        UIApplication.shared.isIdleTimerDisabled = true
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isCallActive = true
        }

        // Ensure the audio session is active
        activateAudioSession()
        
        // Add a realistic delay for premium feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                self.isConnecting = false
                self.isReady = true
            }
        }
        
        // Start the assistant with the existing instance
        Task {
            do {
                try await vapi?.start(
                  assistantId: assistantId,
                  metadata: ["user_name": "Alex", "call_type": "immediate"]
                )
            } catch {
                DispatchQueue.main.async {
                    self.isConnecting = false
                    withAnimation {
                        self.isCallActive = false
                    }
                }
            }
        }
    }
    
    func endCall() {
        isConnecting = false
        isReady = false
        
        // Allow screen to sleep again
        UIApplication.shared.isIdleTimerDisabled = false
        
        Task {
            do {
                try await vapi?.stop()
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.isCallActive = false
                        self.isUserSpeaking = false
                        self.isAssistantSpeaking = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    withAnimation {
                        self.isCallActive = false
                    }
                }
            }
        }
    }
    
    private func setupEventPublisher() {
        vapi?.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self = self else { return }
                
                switch event {
                case .transcript(let transcript):
                    // Show user speaking animation
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.isUserSpeaking = true
                    }
                    
                    // Add a natural delay before ending user speaking state
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            self.isUserSpeaking = false
                        }
                    }
                    
                case .speechUpdate(let update):
                    // Handle speech start/end for assistant
                    switch update.status {
                    case .started:
                        withAnimation(.easeIn(duration: 0.3)) {
                            self.isAssistantSpeaking = true
                        }
                    case .stopped:
                        withAnimation(.easeOut(duration: 0.5)) {
                            self.isAssistantSpeaking = false
                        }
                    @unknown default:
                        break
                    }
                    
                case .callDidStart:
                    print("Call started")
                    
                case .callDidEnd:
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.isCallActive = false
                        self.isUserSpeaking = false
                        self.isAssistantSpeaking = false
                    }
                    
                default:
                    // Handle other events as needed
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    // Call this when the app becomes active in ContentView
    func activateVoiceCompanion() {
        if !isCallActive && !isConnecting {
            startCall()
        }
    }
    
    // Call this when leaving ContentView
    func deactivateVoiceCompanion() {
        if isCallActive || isConnecting {
            endCall()
        }
    }
}
