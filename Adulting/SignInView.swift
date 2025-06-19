//
//  SignInView.swift
//  Auth page view (get started page view, first page when user opens the app first time or after signing out of the app)
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI
import GoogleSignIn

struct SignInView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    @StateObject private var googleAuth = GoogleAuthenticator.shared
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
                Button(action: signInWithGoogle) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.blue)
                            .frame(height: 60)
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        } else {
                            Text("Continue with Google")
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
    
    private func signInWithGoogle() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let user = try await googleAuth.signIn()
                
                // Get the ID token for Firebase authentication
                guard let idToken = user.idToken?.tokenString else {
                    throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])
                }
                
                // Sign in to Firebase with Google credentials
                try await firebaseManager.signInWithGoogle(idToken: idToken, accessToken: user.accessToken.tokenString)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to sign in with Google: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(FirebaseManager.shared)
}
