//
//  OnboardingView.swift
//  Adulting
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    
    @State private var name = ""
    @State private var phoneNumber = ""
    @State private var email = ""
    @State private var currentStep = 0
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    // Default call times (8:00 AM and 9:00 PM)
    @State private var morningCallTime = "8:00 AM"
    @State private var eveningCallTime = "9:00 PM"
    
    // Helper function to create time bindings
    private func timeBinding(for timeString: Binding<String>) -> Binding<Date> {
        Binding<Date>(
            get: {
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                return formatter.date(from: timeString.wrappedValue) ?? Date()
            },
            set: { newDate in
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                timeString.wrappedValue = formatter.string(from: newDate)
            }
        )
    }
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { step in
                        Circle()
                            .fill(step <= currentStep ? Color.blue : Color.gray.opacity(0.5))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 20)
                
                // Step title
                Text(stepTitle)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                // Step content
                VStack(spacing: 25) {
                    switch currentStep {
                    case 0:
                        // Name step
                        TextField("Your Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .autocapitalization(.words)
                    case 1:
                        // Contact info step
                        VStack(spacing: 15) {
                            TextField("Phone Number", text: $phoneNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.phonePad)
                            
                            TextField("Email Address", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        .padding(.horizontal, 20)
                    case 2:
                        // Call schedule step
                        VStack(spacing: 20) {
                            Text("When would you like your daily calls?")
                                .foregroundColor(.white)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 5)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "sunrise.fill")
                                        .foregroundColor(.orange)
                                    Text("Morning Call Time")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                                
                                DatePicker("", selection: timeBinding(for: $morningCallTime), displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                                    .cornerRadius(10)
                                    .accentColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "moon.stars.fill")
                                        .foregroundColor(.indigo)
                                    Text("Evening Call Time")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                                
                                DatePicker("", selection: timeBinding(for: $eveningCallTime), displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                                    .cornerRadius(10)
                                    .accentColor(.blue)
                            }
                        }
                        .padding(.horizontal, 20)
                    default:
                        EmptyView()
                    }
                }
                .frame(height: 250)
                
                // Error message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    // Back button (hidden on first step)
                    if currentStep > 0 {
                        Button(action: {
                            currentStep -= 1
                        }) {
                            Text("Back")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 100)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(25)
                        }
                    } else {
                        Spacer()
                            .frame(width: 100)
                    }
                    
                    Spacer()
                    
                    // Next/Finish button
                    Button(action: {
                        if currentStep < 2 {
                            if validateCurrentStep() {
                                currentStep += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.blue)
                                .frame(width: 100, height: 50)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(currentStep == 2 ? "Finish" : "Next")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .disabled(isLoading)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 0:
            return "What's your name?"
        case 1:
            return "Contact Information"
        case 2:
            return "Call Schedule"
        default:
            return ""
        }
    }
    
    private func validateCurrentStep() -> Bool {
        errorMessage = ""
        
        switch currentStep {
        case 0:
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                errorMessage = "Please enter your name"
                return false
            }
        case 1:
            // Phone validation is optional
            if !email.isEmpty {
                // Simple email validation
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                if !emailPredicate.evaluate(with: email) {
                    errorMessage = "Please enter a valid email address"
                    return false
                }
            }
        default:
            break
        }
        
        return true
    }
    
    private func completeOnboarding() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                // Update user profile with collected information
                try await firebaseManager.updateUserProfile(
                    name: name,
                    phoneNumber: phoneNumber,
                    email: email
                )
                
                // Update call schedule
                try await firebaseManager.updateCallSchedule(
                    morningCallTime: morningCallTime,
                    eveningCallTime: eveningCallTime
                )
                
                // No need to set isLoading to false as the view will be dismissed
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Error saving profile: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(FirebaseManager.shared)
}
