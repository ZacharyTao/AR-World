//
//  ARMainView.swift
//  AR World
//
//  Created by Zachary Tao on 9/7/24.
//

import SwiftUI
import RealityKit
import ARKit
import SwiftData

struct ARMainView: View {
    @State var customARView = CustomARView()
    @State var isBrushMenuPopover = false
    @State var screenshotImage: UIImage?
    @State var showPreview = false
    @State var hidePreviewWorkItem: DispatchWorkItem?
    @State var showLibrary = false
    @State var showSaveSheet: Bool = false
    @State var mapName = ""

    @AppStorage("isFirstTime") var isFirstTime = true
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.modelContext) private var context

    var isPortraitMode: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }

    var body: some View {
        if isFirstTime {
            welcomeSheet
                .transition(.scale)
        } else {
            ZStack {
                ARViewContainer(customARView: customARView)
                    .edgesIgnoringSafeArea(.all)

                optionButton
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                    .zIndex(1)

                if isPortraitMode {
                    // iPhone portrait
                    VStack {
                        Spacer()
                        HStack {
                            buttonView
                        }
                    }
                    .padding(.horizontal, 50)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                } else {
                    // iPhone landscape
                    HStack {
                        Spacer()
                        VStack {
                            buttonView
                        }
                    }
                    .padding(.vertical, 25)
                    .padding(.horizontal, 20)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
                }

                screenShotPreview
                    .zIndex(1)
            }
            .sheet(isPresented: $showLibrary) {
                LibrarySheet()
                    .environment(customARView)
            }
            .alert("Save map", isPresented: $showSaveSheet) {
                TextField("Enter map name", text: $mapName)
                Button("Save") {
                    customARView.saveExperience(mapName: mapName, context: context)
                    mapName = ""
                }
                .disabled(mapName.isEmpty)
                Button("Cancel", role: .cancel) {
                    mapName = ""
                }
            }
        }
    }

    @ViewBuilder
    var buttonView: some View {
        undoButton
        Spacer()
        brushSelectionButton
        Spacer()
        colorPickerButton
        Spacer()
        cameraButton
    }

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

#Preview {
    ARMainView()
}
