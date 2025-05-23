//
//  AudioBar.swift
//  Audio visualization bar component for assistant speaking
//
//  Created by Divya Saini on 5/22/25.
//

import SwiftUI

struct AudioBar: View {
    let color: Color
    let isAnimating: Bool
    let delay: Double
    
    @State private var height: CGFloat = 20
    
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color)
            .frame(width: 4, height: height)
            .onAppear {
                // Initial random height
                height = CGFloat.random(in: 15...60)
                
                // Start animation if needed
                if isAnimating {
                    startAnimation()
                }
            }
            .onChange(of: isAnimating) { newValue in
                if newValue {
                    startAnimation()
                }
            }
    }
    
    private func startAnimation() {
        // Continuous animation for audio bars
        withAnimation(Animation.easeInOut(duration: 0.5)
            .repeatForever(autoreverses: true)
            .delay(delay)) {
                height = CGFloat.random(in: 40...100)
        }
    }
}
