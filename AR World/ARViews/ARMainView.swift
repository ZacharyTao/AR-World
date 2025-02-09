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
    // Screenshot
    @State var screenshotImage: UIImage?
    @State var showPreview = false
    @State var hidePreviewWorkItem: DispatchWorkItem?
    // Loading
    @State var showLibrary = false
    // Saving
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
            WelcomeOnBoardView(isFirstTime: $isFirstTime)
                .transition(.scale)
        } else {
            ZStack {
                ARViewContainer(customARView: customARView)
                    .edgesIgnoringSafeArea(.all)

                if customARView.isLoadingMap {
                    resetButton
                    thumbnailImage
                        .zIndex(2)
                } else if customARView.isSavingMap {
                    resetButton
                    saveButton
                        .zIndex(1)
                } else {
                    optionButton
                        .zIndex(1)
                    buttonView
                }

                sessionInfo
                screenShotPreview
                    .zIndex(1)

            }
            .animation(.default, value: customARView.isLoadingMap)
            .animation(.default, value: customARView.isSavingMap)
            .animation(.default, value: customARView.sessionInfoLabel)
            .fullScreenCover(isPresented: $showLibrary) {
                LibrarySheet()
                    .environment(customARView)
            }
            .alert("Save map", isPresented: $showSaveSheet) {
                TextField("Enter map name", text: $mapName)
                Button("Save") {
                    customARView.saveExperience(mapName: mapName, context: context)
                    mapName = ""
                    customARView.isSavingMap = false
                }
                .disabled(mapName.isEmpty)
                Button("Cancel", role: .cancel) {
                    mapName = ""
                    customARView.isSavingMap = false
                }
            }
        }
    }

    @ViewBuilder
    var sessionInfo: some View {
        if let labelText = customARView.sessionInfoLabel,
           !labelText.isEmpty
        {
            VStack {
                Spacer()
                Text(labelText)
                    .multilineTextAlignment(.center)
                    .padding(5)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                    .padding(.bottom, isIPhone() ? 90: 150)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }

    @ViewBuilder
    var thumbnailImage: some View {
        if let image = customARView.thumbnailImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: isIPhone() ? 120: 350)
                .cornerRadius(20)
                .shadow(radius: 5)
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .topTrailing)
                .padding()
        }
    }

    @ViewBuilder
    var buttonView: some View {
        if isPortraitMode {
            // iPhone portrait
            VStack {
                Spacer()
                HStack {
                    undoButton
                    Spacer()
                    brushSelectionButton
                    Spacer()
                    colorPickerButton
                    Spacer()
                    cameraButton
                }
            }
            .padding(.horizontal, 50)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        } else {
            // iPhone landscape
            HStack {
                Spacer()
                VStack {
                    undoButton
                    Spacer()
                    brushSelectionButton
                    Spacer()
                    colorPickerButton
                    Spacer()
                    cameraButton
                }
            }
            .padding(.vertical, 25)
            .padding(.horizontal, 20)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
}

#Preview {
    ARMainView()
}
