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

                } label: {
                    Label("Save Drawing", systemImage: "square.and.arrow.down")
                }

                Button {

                } label: {
                    Label("Load Drawing", systemImage: "square.and.arrow.up")
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
    }
}
