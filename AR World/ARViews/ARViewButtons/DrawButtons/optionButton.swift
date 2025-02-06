//
//  optionButton.swift
//  AR World
//
//  Created by Zachary Tao on 1/17/25.
//

import SwiftUI

extension ARMainView {
    var optionButton: some View {
        Menu {
            Section {
                Button(role: .destructive) {
                    customARView.clearAllStrokes()
                } label: {
                    Label("Clear Strokes", systemImage: "trash")
                }
            }

            Section {
                Button {
                    // showSaveSheet.toggle()
                    customARView.isSavingMap = true
                } label: {
                    Label("Save Drawing", systemImage: "square.and.arrow.down")
                }
                .disabled(customARView.document.isEmpty)

                Button {
                    showLibrary = true
                } label: {
                    Label("Load Drawing", systemImage: "square.and.arrow.up")
                }
            }

            Section {
                Button {

                } label: {
                    Label("Settings", systemImage: "gear")
                }
            }
        } label: {
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .frame(width: isIPhone() ? 30 : 60)
                .foregroundStyle(.white)
                .bold()
                .padding(10)
                .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.vertical, isPortraitMode ? 5 : 20)
        .padding(.horizontal, isPortraitMode ? 15: 30)
    }
}
