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
    
    var body: some View {
        ZStack{
            ARViewContainer(customARView: customARView).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Button{
                        customARView.undoLastStroke()
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    }label: {
                        Image(systemName: "arrow.uturn.backward")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                            .foregroundStyle(.white)
                            .bold()
                    }
                    
                    Spacer()
                    
                    
                    Button{
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                        isBrushMenuPopover.toggle()
                    }label: {
                        Image(systemName: "paintbrush.pointed")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30)
                            .foregroundStyle(.white)
                            .bold()
                    }.popover(isPresented: $isBrushMenuPopover, attachmentAnchor: .point(.top), arrowEdge: .bottom, content: {
                        BrushSelectionView
                            .presentationBackground(.ultraThinMaterial)
                            .presentationCompactAdaptation(.popover)
                    })
                    
                    Spacer()
                    
                    ColorPicker("", selection: $customARView.selectedColor, supportsOpacity: false)
                        .labelsHidden()
                        .frame(width: 30)
                    
                    Spacer()
                    
                    Button{
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                        customARView.snapshot(saveToHDR: true){image in
                            guard let image else { return }
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
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
            .padding(.horizontal, 50)
        }
    }
    
    var BrushSelectionView: some View{
        HStack(spacing: 5){
            
            Button {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                customARView.selectedRadius = .thin
                isBrushMenuPopover = false
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.regularMaterial)
                    .opacity(customARView.selectedRadius == .thin ? 1 : 0)
                    .overlay{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(customARView.selectedColor)
                            .frame(width: 30, height: 3)
                    }
                    .padding(1)
            }
            
            Button {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                customARView.selectedRadius = .medium
                isBrushMenuPopover = false
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.regularMaterial)
                    .opacity(customARView.selectedRadius == .medium ? 1 : 0)
                    .overlay{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(customARView.selectedColor)
                            .frame(width: 30, height: 6)
                    }
                    .padding(1)
            }
            
            Button {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                customARView.selectedRadius = .wide
                isBrushMenuPopover = false
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.regularMaterial)
                    .opacity(customARView.selectedRadius == .wide ? 1 : 0)
                    .overlay{
                        RoundedRectangle(cornerRadius: 10)
                            .fill(customARView.selectedColor)
                            .frame(width: 30, height: 9)
                    }
                    .padding(1)
            }
        }.padding(.horizontal, 3)
    }
}
enum BrushRadius: Float{
    case thin = 0.005
    case medium = 0.008
    case wide = 0.012
}


#Preview {
    ARMainView()
}


