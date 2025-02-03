//
//  BrushSelectionView.swift
//  AR World
//
//  Created by Zachary Tao on 9/17/24.
//
import SwiftUI

extension ARMainView {
    var brushSelectionButton: some View {
        Button {
            isBrushMenuPopover.toggle()
        }label: {
            Image(systemName: "paintbrush.pointed")
                .resizable()
                .scaledToFit()
                .frame(width: isIPhone() ? 30 : 60)
                .foregroundStyle(.white)
                .bold()
        }.popover(isPresented: $isBrushMenuPopover,
                  attachmentAnchor: isPortraitMode ? .point(.top) : .point(.leading),
                  arrowEdge: isPortraitMode ? .bottom : .trailing, content: {
            brushSelectionView
                .presentationBackground(customARView.selectedColor.selectedMenuBackground)
                .presentationCompactAdaptation(.popover)
        })
    }

    var brushSelectionView: some View {
        HStack(spacing: 3) {
            VStack(spacing: 5) {
                Button {
                    customARView.selectedRadius = .thin
                    isBrushMenuPopover = false
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(customARView.selectedColor.selectedBackground)
                        .opacity(customARView.selectedRadius == .thin ? 1 : 0)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(customARView.selectedColor)
                                .frame(width: 30, height: 3)
                        }
                }

                Button {
                    customARView.selectedRadius = .medium
                    isBrushMenuPopover = false
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(customARView.selectedColor.selectedBackground)
                        .opacity(customARView.selectedRadius == .medium ? 1 : 0)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(customARView.selectedColor)
                                .frame(width: 30, height: 6)
                        }
                }

                Button {
                    customARView.selectedRadius = .wide
                    isBrushMenuPopover = false
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(customARView.selectedColor.selectedBackground)
                        .opacity(customARView.selectedRadius == .wide ? 1 : 0)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(customARView.selectedColor)
                                .frame(width: 30, height: 9)
                        }
                }
            }

            VStack(spacing: 5) {
                Button {
                    customARView.selectedBrushMaterial = .basic
                    isBrushMenuPopover = false
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 100, height: 60)
                        .foregroundStyle(customARView.selectedColor.selectedBackground)
                        .opacity(customARView.selectedBrushMaterial == .basic ? 1 : 0)
                        .overlay {
                            Text("Basic")
                                .foregroundStyle(customARView.selectedColor)
                        }
                }

                Button {
                    customARView.selectedBrushMaterial = .realistic
                    isBrushMenuPopover = false
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 100, height: 60)
                        .foregroundStyle(customARView.selectedColor.selectedBackground)
                        .opacity(customARView.selectedBrushMaterial == .realistic ? 1 : 0)
                        .overlay {
                            Text("Realistic")
                                .foregroundStyle(customARView.selectedColor)
                        }
                }

                Button {
                    customARView.selectedBrushMaterial = .metallic
                    isBrushMenuPopover = false
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 100, height: 60)
                        .foregroundStyle(customARView.selectedColor.selectedBackground)
                        .opacity(customARView.selectedBrushMaterial == .metallic ? 1 : 0)
                        .overlay {
                            Text("Metallic")
                                .foregroundStyle(customARView.selectedColor)
                        }
                }
            }
        }
        .padding(4)
    }
}

extension Color {
    var isDark: Bool {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        let brightness = (red * 299 + green * 587 + blue * 114) / 1000
        return brightness < 0.5
    }

    var selectedBackground: Color {
        isDark ? Color.white.opacity(0.9) : Color.gray.opacity(0.2)
    }

    var selectedMenuBackground: Color {
        isDark ? Color.gray.opacity(0.03) : Color.gray.opacity(0.1)
    }

    var contrast: Color {
        isDark ? .white : .black
    }
}
