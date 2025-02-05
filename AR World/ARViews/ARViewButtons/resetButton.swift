//
//  resetButton.swift
//  AR World
//
//  Created by Zachary Tao on 2/5/25.
//

import SwiftUI

extension ARMainView {
    var resetButton: some View {
        Button{
            if customARView.isLoadingMap {
                customARView.resetSession()
            }
            if customARView.isSavingMap {
                customARView.isSavingMap = false
                customARView.sessionInfoLabel = ""
            }
        } label: {
            Text("Cancel")
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.red.opacity(0.7))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()

    }
}
