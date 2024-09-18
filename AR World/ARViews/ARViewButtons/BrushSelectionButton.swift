//
//  BrushSelectionView.swift
//  AR World
//
//  Created by Zachary Tao on 9/17/24.
//
import SwiftUI

extension ARMainView{
    var BrushSelectionButton: some View {
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
    }
    
    var BrushSelectionView: some View{
        HStack(spacing: 3){
            VStack(spacing: 5){
                
                Button {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    customARView.selectedRadius = .thin
                    isBrushMenuPopover = false
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.thinMaterial)
                        .opacity(customARView.selectedRadius == .thin ? 1 : 0)
                        .overlay{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(customARView.selectedColor)
                                .frame(width: 30, height: 3)
                        }
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    customARView.selectedRadius = .medium
                    isBrushMenuPopover = false
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.thinMaterial)
                        .opacity(customARView.selectedRadius == .medium ? 1 : 0)
                        .overlay{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(customARView.selectedColor)
                                .frame(width: 30, height: 6)
                        }
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    customARView.selectedRadius = .wide
                    isBrushMenuPopover = false
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.thinMaterial)
                        .opacity(customARView.selectedRadius == .wide ? 1 : 0)
                        .overlay{
                            RoundedRectangle(cornerRadius: 10)
                                .fill(customARView.selectedColor)
                                .frame(width: 30, height: 9)
                        }
                }
            }
            
            VStack(spacing: 5){
                
                Button {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    customARView.selectedBrushMaterial = .basic
                    isBrushMenuPopover = false
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 100, height: 60)
                        .foregroundStyle(.thinMaterial)
                        .opacity(customARView.selectedBrushMaterial == .basic ? 1 : 0)
                        .overlay{
                            Text("Basic")
                                .foregroundStyle(customARView.selectedColor)
                        }
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    customARView.selectedBrushMaterial = .realistic
                    isBrushMenuPopover = false
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 100, height: 60)
                        .foregroundStyle(.thinMaterial)
                        .opacity(customARView.selectedBrushMaterial == .realistic ? 1 : 0)
                        .overlay{
                            Text("Realistic")
                                .foregroundStyle(customARView.selectedColor)

                        }
                }
                
                Button {
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    customARView.selectedBrushMaterial = .metallic
                    isBrushMenuPopover = false
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 100, height: 60)
                        .foregroundStyle(.thinMaterial)
                        .opacity(customARView.selectedBrushMaterial == .metallic ? 1 : 0)
                        .overlay{
                            Text("Metallic")
                                .foregroundStyle(customARView.selectedColor)
                        }
                }
            }
        }
        .padding(4)
    }
}
