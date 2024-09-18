//
//  CameraButton.swift
//  AR World
//
//  Created by Zachary Tao on 9/17/24.
//

import SwiftUI

extension ARMainView{

    @ViewBuilder
    var ScreenShotPreview: some View {
        if showPreview, let screenshotImage = screenshotImage {
            Image(uiImage: screenshotImage)
                .resizable()
                .scaledToFit()
                .frame(width: 80)
                .cornerRadius(20)
                .overlay{
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white, lineWidth: 4)
                }
                .shadow(radius: 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .transition(.move(edge: .trailing))
                .padding()
        }
    }
    
    var CameraButton: some View{
        Button{
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            customARView.snapshot(saveToHDR: true) { image in
                guard let image else { return }
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                screenshotImage = image
                    
                    withAnimation  (.bouncy) {
                        showPreview = true
                    }
                
                hidePreviewWorkItem?.cancel()
                
                // Create a new hide action
                hidePreviewWorkItem = DispatchWorkItem {
                    withAnimation (.bouncy.speed(0.4)) {
                        showPreview = false
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: hidePreviewWorkItem!)

                
            }
        }label: {
            Image(systemName: "camera")
                .resizable()
                .scaledToFit()
                .frame(width: 30)
                .foregroundStyle(.white)
                .bold()
        }
    }
}
