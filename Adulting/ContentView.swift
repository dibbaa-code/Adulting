//
//  ContentView.swift
//  Adulting
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isListening = true
    @State private var animationAmount = 1.0
    
    // Colors for the audio visualization bars
    let barColors: [Color] = [
        .pink, .yellow, .green, .blue, .purple, .yellow, .pink,
        .blue, .purple, .green, .yellow, .pink, .blue, .green
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color 
                Color.black.ignoresSafeArea()
                
                VStack {
                    // Greeting heading
                    Text("Hello! How can I help you?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // Audio visualization circle
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                            .frame(width: 280, height: 280)
                        
                        // Audio visualization bars
                        HStack(spacing: 4) {
                            ForEach(0..<14) { index in
                                AudioBar(color: barColors[index], isAnimating: isListening, delay: Double(index) * 0.05)
                            }
                        }
                    }
                    .padding(.bottom, 80)
                    
                    Spacer()
                    
                    // Bottom control buttons
                    HStack(spacing: 50) {
                        // Microphone button for muting/unmuting
                        Button(action: {
                            isListening.toggle()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.2, green: 0.2, blue: 0.2))
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: isListening ? "mic.fill" : "mic.slash.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Notes/Transcript button
                        Button(action: {
                            // Action for notes
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.2, green: 0.2, blue: 0.2))
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "doc.text.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Profile button
                        NavigationLink(destination: ProfileView()) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.2, green: 0.2, blue: 0.2))
                                    .frame(width: 70, height: 70)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
