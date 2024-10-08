//
//  CameraButton.swift
//  AR World
//
//  Created by Zachary Tao on 9/17/24.
//

import SwiftUI

extension ARMainView {
    
    @ViewBuilder
    var screenShotPreview: some View {
        if showPreview, let screenshotImage = screenshotImage {
            Image(uiImage: screenshotImage)
                .resizable()
                .scaledToFit()
                .frame(width: isIPhone() ? (isPortraitMode ? 80 : 150) : 200)
                .cornerRadius(20)
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white, lineWidth: 4)
                }
                .shadow(radius: 5)
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: isPortraitMode ? .topTrailing : .topLeading)
                .transition(isPortraitMode ? .move(edge: .trailing) : .move(edge: .leading))
                .padding()
        }
    }
    
    var cameraButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            customARView.snapshot(saveToHDR: true) { image in
                guard let image else { return }
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                screenshotImage = image
                withAnimation(.bouncy) {
                    showPreview = true
                }
                
                hidePreviewWorkItem?.cancel()
                
                // Create a new hide action
                hidePreviewWorkItem = DispatchWorkItem {
                    withAnimation(.bouncy.speed(0.4)) {
                        showPreview = false
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: hidePreviewWorkItem!)
                
            }
        }label: {
            Image(systemName: "camera")
                .resizable()
                .scaledToFit()
                .frame(width: isIPhone() ? 30 : 60)
                .foregroundStyle(.white)
                .bold()
        }
    }
}
