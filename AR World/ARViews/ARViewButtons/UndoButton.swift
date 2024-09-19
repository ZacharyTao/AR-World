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
            Image(systemName: "arrow.uturn.backward.circle")
                .resizable()
                .scaledToFit()
                .frame(width: isIPhone() ? 30 : 60)
                .foregroundStyle(.white)
                .bold()
        }
    }
}
