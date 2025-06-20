//
//  ProfileView.swift
//  Profile page view where user can see their profile details and sign out of the app
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI
import Firebase

struct ProfileView: View {
    @EnvironmentObject private var firebaseManager: FirebaseManager
    
    // Helper function for toggling calls
    private func toggleCalls() {
        DispatchQueue.main.async {
            Task {
                do {
                    try await self.firebaseManager.toggleCallsEnabled()
                } catch {
                    print("Error toggling calls: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Editable states
    @State private var userName: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var morningCallTime: String = ""
    @State private var eveningCallTime: String = ""
    
    // UI states
    @State private var isEditingName = false
    @State private var isEditingPhone = false
    @State private var isEditingEmail = false
    @State private var isEditingSchedule = false
    @State private var showSignOutAlert = false
    @State private var showDisableCallsAlert = false
    @State private var isDisablingCalls = false
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Profile header with streak
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                        
                        if isEditingName {
                            TextField("Name", text: $userName)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                                .cornerRadius(10)
                                .padding(.horizontal, 40)
                                .onSubmit {
                                    updateName()
                                }
                        } else {
                            Text(userName.isEmpty ? "Set Your Name" : userName)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .onTapGesture {
                                    isEditingName = true
                                }
                        }
                        
                        // Streak display
                        HStack(spacing: 10) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            
                            Text("\(firebaseManager.userProfile?.callStreak ?? 0) Day Streak")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                        .cornerRadius(25)
                    }
                    .padding(.top, 20)
                    
                    // Call Schedule Section
                    sectionCard(title: "Call Schedule") {
                        VStack(spacing: 20) {
                            scheduleRow(title: "Morning Call", time: morningCallTime, icon: "sunrise.fill", color: .orange)
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            scheduleRow(title: "Evening Call", time: eveningCallTime, icon: "moon.stars.fill", color: .indigo)
                        }
                    }
                    
                    // Account Section
                    sectionCard(title: "Account") {
                        VStack(spacing: 20) {
                            if isEditingPhone {
                                HStack {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    
                                    TextField("Phone Number", text: $phoneNumber)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                                        .cornerRadius(8)
                                    
                                    Button(action: {
                                        updatePhone()
                                    }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                            } else {
                                infoRow(title: "Phone Number", value: phoneNumber, icon: "phone.fill")
                                    .onTapGesture {
                                        isEditingPhone = true
                                    }
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            if isEditingEmail {
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.blue)
                                        .frame(width: 30)
                                    
                                    TextField("Email", text: $email)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color(red: 0.2, green: 0.2, blue: 0.25))
                                        .cornerRadius(8)
                                    
                                    Button(action: {
                                        updateEmail()
                                    }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                            } else {
                                infoRow(title: "Email", value: email, icon: "envelope.fill")
                                    .onTapGesture {
                                        isEditingEmail = true
                                    }
                            }
                        }
                    }
                    
                    // Sign Out Section
                    sectionCard(title: "Actions") {
                        // Calls Enabled Toggle
                        HStack {
                            Image(systemName: firebaseManager.userProfile?.callsEnabled == true ? "phone" : "phone.down")
                                .foregroundColor(firebaseManager.userProfile?.callsEnabled == true ? .green : .orange)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Phone Calls")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(firebaseManager.userProfile?.callsEnabled == true ? "Calls are enabled" : "Calls are disabled")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            if isDisablingCalls {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Toggle("", isOn: Binding(
                                    get: { firebaseManager.userProfile?.callsEnabled ?? true },
                                    set: { newValue in
                                        DispatchQueue.main.async {
                                            if newValue {
                                                // Enabling calls - do it immediately
                                                toggleCalls()
                                            } else {
                                                // Disabling calls - show confirmation alert
                                                showDisableCallsAlert = true
                                            }
                                        }
                                    }
                                ))
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                            }
                        }
                        .padding(.vertical, 5)
                        .alert("Disable Calls", isPresented: $showDisableCallsAlert) {
                            Button("Cancel", role: .cancel) { }
                            Button("Disable Calls", role: .destructive) {
                                toggleCalls()
                            }
                        } message: {
                            Text("Are you sure you want to disable calls?")
                        }
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        // Sign Out Button
                        Button(action: {
                            showSignOutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                    .frame(width: 30)
                                
                                Text("Sign Out")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                        }
                        .padding(.vertical, 5)
                        .alert("Sign Out", isPresented: $showSignOutAlert) {
                            Button("Cancel", role: .cancel) { }
                            Button("Sign Out", role: .destructive) {
                                signOut()
                            }
                        } message: {
                            Text("Are you sure you want to sign out?")
                        }
                    }
                    .padding(.bottom, 30)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            loadUserData()
        }
    }
    
    // MARK: - Data Loading
    
    private func loadUserData() {
        if let profile = firebaseManager.userProfile {
            userName = profile.name
            phoneNumber = profile.phoneNumber
            email = profile.email
            morningCallTime = profile.morningCallTime
            eveningCallTime = profile.eveningCallTime
        }
    }
    
    // MARK: - Update Methods
    
    private func updateName() {
        isEditingName = false
        Task {
            do {
                try await firebaseManager.updateUserProfile(name: userName)
            } catch {
                print("Error updating name: \(error.localizedDescription)")
            }
        }
    }
    
    private func updatePhone() {
        isEditingPhone = false
        Task {
            do {
                try await firebaseManager.updateUserProfile(phoneNumber: phoneNumber)
            } catch {
                print("Error updating phone: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateEmail() {
        isEditingEmail = false
        Task {
            do {
                try await firebaseManager.updateUserProfile(email: email)
            } catch {
                print("Error updating email: \(error.localizedDescription)")
            }
        }
    }
    
    private func updateCallSchedule() {
        isEditingSchedule = false
        Task {
            do {
                try await firebaseManager.updateCallSchedule(
                    morningCallTime: morningCallTime,
                    eveningCallTime: eveningCallTime
                )
            } catch {
                print("Error updating call schedule: \(error.localizedDescription)")
            }
        }
    }
    
    private func signOut() {
        do {
            try firebaseManager.signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    // Helper Views
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.leading, 5)
            
            VStack {
                content()
            }
            .padding()
            .background(Color(red: 0.2, green: 0.2, blue: 0.25))
            .cornerRadius(15)
        }
    }
    
    private func statItem(value: String, label: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading) {
                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func scheduleRow(title: String, time: String, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(time)
                .foregroundColor(.white)
                .font(.headline)
        }
    }
    
    private func infoRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
    
    private func settingsRow(title: String, icon: String) -> some View {
        Button(action: {
            // Navigate to specific setting
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
    }
    
    // Helper Functions
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

#Preview {
    ProfileView()
}
