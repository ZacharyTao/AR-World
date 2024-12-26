//
//  ARMainView.swift
//  AR World
//
//  Created by Zachary Tao on 9/7/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ARMainView: View {
    @State var customARView = CustomARView()
    @State var isBrushMenuPopover = false
    @State var screenshotImage: UIImage?
    @State var showPreview = false
    @State var hidePreviewWorkItem: DispatchWorkItem?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var isPortraitMode: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
    
    var body: some View {
        ZStack {
            ARViewContainer(customARView: customARView)
                .edgesIgnoringSafeArea(.all)

            if isPortraitMode {
                // iPhone portrait
                VStack {
                    Spacer()
                    HStack {
                        buttonView
                    }
                }
                .padding(.horizontal, 50)
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
            }

            screenShotPreview
                .zIndex(1)
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
}

#Preview {
    ARMainView()
}
