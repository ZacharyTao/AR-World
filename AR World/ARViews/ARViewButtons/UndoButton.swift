//
//  UndoButton.swift
//  AR World
//
//  Created by Zachary Tao on 9/17/24.
//

import SwiftUI

extension ARMainView{
    var UndoButton: some View{
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
    }
}
