//
//  ARMainView.swift
//  AR World
//
//  Created by Zachary Tao on 9/7/24.
//

import SwiftUI
import RealityKit
import ARKit


struct ARMainView : View {
    @StateObject var customARView = CustomARView()
    @State var isBrushMenuPopover = false
    @State var screenshotImage: UIImage?
    @State var showPreview = false
    @State var hidePreviewWorkItem: DispatchWorkItem?
    
    
    
    var body: some View {
        ZStack {
            ARViewContainer(customARView: customARView)
                .edgesIgnoringSafeArea(.all)
            
            // Main UI Elements
            VStack {
                Spacer()
                HStack {
                    UndoButton
                    Spacer()
                    BrushSelectionButton
                    Spacer()
                    ColorPickerButton
                    Spacer()
                    CameraButton
                }
            }
            .padding(.horizontal, 50)
            
            // Screenshot Preview
            ScreenShotPreview
                .zIndex(1)
            
            // Tracking State Message
            if customARView.cameraTrackingMessageIsShowing {
                VStack(spacing: 20) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                        .padding(20)
                    Text(customARView.trackingStateTitleLabel)
                        .bold()
                    Text(customARView.trackingStateMessageLabel)
                        .font(.caption)
                }
                .foregroundStyle(.white)
                .opacity(0.8)
                .padding()
                .transition(.opacity)
                .zIndex(2)
            }
        }
        .animation(.bouncy, value: customARView.cameraTrackingMessageIsShowing)
    }
}

#Preview {
    ARMainView()
}


