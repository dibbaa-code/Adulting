//
//  SignInView.swift
//  Adulting
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI

struct SignInView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App logo/icon
                Image(systemName: "person.and.background.dotted")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .padding(.bottom, 20)
                
                // App name
                Text("Adulting")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(.white)
                
                // App description
                Text("Your daily voice companion")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.bottom, 60)
                
                // Welcome message
                Text("Welcome to your personal daily assistant")
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                
                // Sign in button
                Button(action: signInAnonymously) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.blue)
                            .frame(height: 60)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        } else {
                            Text("Get Started")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .disabled(isLoading)
                
                // Error message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
                
                // Privacy note
                Text("Your information is private and secure")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
            }
            .padding()
        }
    }
    
    private func signInAnonymously() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await firebaseManager.signInAnonymously()
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to sign in: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(FirebaseManager.shared)
}
