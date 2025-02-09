//
//  OnBoardView.swift
//  AR World
//
//  Created by Zachary Tao on 2/8/25.
//

import SwiftUI

struct WelcomeOnBoardView: View {
    @State private var selectedIndex = 0
    @Binding var isFirstTime: Bool
    var body: some View {
        TabView(selection: $selectedIndex) {
            OnBoardView(systemImageName: "scribble.variable",
                        title: "Sketch in 3D",
                        description: "Tap to draw and create freely in the 3D world.",
                        viewIndex: 0,
                        selectedIndex: $selectedIndex,
                        isFirstTime: $isFirstTime
            )
                .tag(0)

            OnBoardView(systemImageName: "paintpalette",
                        title: "Customize Your Brush",
                        description: "Experiment with different brushes and materials.",
                        viewIndex: 1,
                        selectedIndex: $selectedIndex,
                        isFirstTime: $isFirstTime
            )
                .tag(1)

            OnBoardView(systemImageName: "camera",
                        title: "Capture Your Artwork",
                        description: "Take snapshots of your 3D drawings and share them.",
                        viewIndex: 2,
                        selectedIndex: $selectedIndex,
                        isFirstTime: $isFirstTime
            )
                .tag(2)

            OnBoardView(systemImageName: "square.and.arrow.down",
                        title: "Save Your Creations",
                        description: "Store your artwork and revisit your designs anytime.",
                        viewIndex: 3,
                        selectedIndex: $selectedIndex,
                        isFirstTime: $isFirstTime
            )
                .tag(3)

            WelcomeView(selectedIndex: $selectedIndex, isFirstTime: $isFirstTime)
                .tag(4)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(LinearGradient(
            gradient: Gradient(colors: [.white, Color.accentColor.opacity(0.3)]),
            startPoint: .top,
            endPoint: .bottom).ignoresSafeArea())
    }
}

struct WelcomeView: View {
    @Binding var selectedIndex: Int
    @Binding var isFirstTime: Bool
    @State private var animate: Bool = false

    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            Spacer()
            Text("Welcome to AR World!")
                .font(.largeTitle)
                .bold()
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -40)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: animate)

            Image("Welcome")
                .resizable()
                .scaledToFit()
                .frame(width: isIPhone() ? UIScreen.main.bounds.width * 0.8 : UIScreen.main.bounds.width * 0.7)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -100)
                .scaleEffect(animate ? 1 : 0.5)
                .rotationEffect(.degrees(animate ? 0 : -15))
                .animation(.interpolatingSpring(stiffness: 30, damping: 8).delay(0.1), value: animate)

            Text("Unleash your creativity in a 3D space!")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -40)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: animate)
                .padding(20)
                .padding(.horizontal, 20)


            Spacer()

            Button {
                withAnimation {
                    isFirstTime = false
                }
            } label: {
                Text("Get Started")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(15)
                    .background(Color.accentColor)
                    .cornerRadius(15)
                    .shadow(color: Color.accentColor.opacity(0.5), radius: 5, x: 0, y: 3)
            }
            .frame(width: isIPhone() ? 200 : 400)
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : -40)
            .animation(.easeOut(duration: 0.6).delay(0.7), value: animate)

            Spacer()
        }
        .onAppear {
            withAnimation(.easeIn(duration: 2.5)) {
                animate = true
            }
        }
        .onDisappear {
            animate = false
        }
    }
}

struct OnBoardView: View {
    let systemImageName: String
    let title: String
    let description: String
    var isLastOne: Bool = false
    var viewIndex: Int
    @Binding var selectedIndex: Int
    @Binding var isFirstTime: Bool
    @State private var animate: Bool = false

    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            Spacer()

            Image(systemName: systemImageName)
                .resizable()
                .scaledToFit()
                .frame(width: isIPhone() ? 150 : 200)
                .foregroundStyle(.accent)
                .shadow(color: Color.accentColor.opacity(0.4), radius: 2)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -60)
                .scaleEffect(animate ? 1 : 0.8)
                .rotationEffect(.degrees(animate ? 0 : -15))
                .animation(.interpolatingSpring(stiffness: 40, damping: 10).delay(0.1), value: animate)

            Text(title)
                .font(.title)
                .bold()
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -40)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: animate)

            Text(description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -40)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: animate)
                .padding(20)
                .padding(.horizontal, 20)

            Spacer()

            if isLastOne {
                Button {
                    withAnimation {
                        isFirstTime = false
                    }
                } label: {
                    Text("Get Started")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(15)
                        .background(Color.accentColor)
                        .cornerRadius(15)
                        .shadow(color: Color.accentColor.opacity(0.5), radius: 5, x: 0, y: 3)
                }
                .frame(width: isIPhone() ? 200 : 400)
                .opacity(animate ? 1 : 0)
                .offset(y: animate ? 0 : -40)
                .animation(.easeOut(duration: 0.6).delay(0.7), value: animate)
            }

            Spacer()
        }
        .onAppear {
            if selectedIndex == 0 {
                withAnimation(.easeOut(duration: 1.5)) {
                    animate = true
                }
            }
        }
        .onChange(of: selectedIndex) {
            withAnimation(.easeOut(duration: 1.5)) {
                animate = selectedIndex == viewIndex
            }

        }
        .onDisappear {
            animate = false
        }
    }
}
