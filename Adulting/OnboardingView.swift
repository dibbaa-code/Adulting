//
//  OnboardingView.swift
//  User onboarding view where system asks questions like name, email, phone, call schedule etc.
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    
    @State private var phoneNumber = ""
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
                    ForEach(0..<2) { step in
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
                        // Phone number step
                        TextField("Phone Number", text: $phoneNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                            .padding(.horizontal, 20)
                    case 1:
                        // Call schedule step
                        VStack(spacing: 25) {
                            // Morning call time selector
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "sunrise.fill")
                                        .foregroundColor(.orange)
                                        .font(.system(size: 18))
                                    Text("Morning Call Time")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                                .padding(.horizontal, 5)
                                
                                DatePicker("", selection: timeBinding(for: $morningCallTime), displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .frame(height: 100)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                                    .cornerRadius(10)
                                    .accentColor(.blue)
                            }
                            .padding(.bottom, 10)
                            
                            // Evening call time selector
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "moon.stars.fill")
                                        .foregroundColor(.indigo)
                                        .font(.system(size: 18))
                                    Text("Evening Call Time")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                }
                                .padding(.horizontal, 5)
                                
                                DatePicker("", selection: timeBinding(for: $eveningCallTime), displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .datePickerStyle(WheelDatePickerStyle())
                                    .frame(height: 100)
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
                .frame(height: 350)
                
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
                        if currentStep < 1 {
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
                                Text(currentStep == 1 ? "Finish" : "Next")
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
            return "Phone Number"
        case 1:
            return "Call Schedule"
        default:
            return ""
        }
    }
    
    private func validateCurrentStep() -> Bool {
        errorMessage = ""
        
        switch currentStep {
        case 0:
            // Phone validation is optional
            return true
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
                    phoneNumber: phoneNumber
                )
                
                // Update call schedule
                try await firebaseManager.updateCallSchedule(
                    morningCallTime: morningCallTime,
                    eveningCallTime: eveningCallTime
                )
                
                // No need to set isLoading to false as the view will be dismissed
                
                // Track onboarding completion
                PostHogManager.shared.trackOnboardingComplete(steps: 2)
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
