//
//  ProfileView.swift
//  Adulting
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI

struct ProfileView: View {
    // Sample user data
    @State private var userName = "Alex Smith"
    @State private var phoneNumber = "+1 (555) 123-4567"
    @State private var email = "alex@example.com"
    @State private var callStreak = 3
    
    // Call schedule
    @State private var morningCallTime = Date(timeIntervalSince1970: 
                                             TimeInterval(8 * 3600)) // 8:00 AM default
    @State private var eveningCallTime = Date(timeIntervalSince1970: 
                                             TimeInterval(21 * 3600)) // 9:00 PM default
    
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
                        
                        Text(userName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Streak display
                        HStack(spacing: 10) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            
                            Text("\(callStreak) Day Streak")
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
                            infoRow(title: "Phone Number", value: phoneNumber, icon: "phone.fill")
                            
                            Divider()
                                .background(Color.gray.opacity(0.3))
                            
                            infoRow(title: "Email", value: email, icon: "envelope.fill")
                        }
                    }
                    
                    // Sign Out Section
                    sectionCard(title: "Actions") {
                        Button(action: {
                            // Sign out action
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
                    }
                    .padding(.bottom, 30)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
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
    
    private func scheduleRow(title: String, time: Date, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(formatTime(time))
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
