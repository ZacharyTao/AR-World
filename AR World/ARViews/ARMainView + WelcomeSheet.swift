//
//  ARMainView + WelcomeSheet.swift
//  AR World
//
//  Created by Zachary Tao on 2/5/25.
//

import SwiftUI

extension ARMainView {
    var welcomeSheet: some View {
        VStack {
            Text("Welcome to AR World")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text("Unleash your creativity in a 3D space!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 15) {
                FeatureItem(icon: "pencil", text: "Draw in 3D by tapping on screen")
                FeatureItem(icon: "paintpalette", text: "Explore various brushes and materials")
                FeatureItem(icon: "camera", text: "Capture and share your creations")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 20)

            Button {
                withAnimation {
                    isFirstTime = false
                }
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
        .transition(.scale)
    }

    struct FeatureItem: View {
        let icon: String
        let text: String

        var body: some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .frame(width: 24, height: 24)
                Text(text)
                    .font(.subheadline)
            }
        }
    }
}

