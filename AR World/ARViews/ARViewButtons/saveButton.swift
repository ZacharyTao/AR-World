//
//  saveButton.swift
//  AR World
//
//  Created by Zachary Tao on 2/5/25.
//

import SwiftUI

extension ARMainView {
    var saveButton: some View {
        Button {
            showSaveSheet = true
        } label: {
            Text("Save Map")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(customARView.isSaveButtonEnabled ? Color.accentColor : Color.gray)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .disabled(!customARView.isSaveButtonEnabled)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, isIPhone() ? 40: 70)
        .edgesIgnoringSafeArea(.bottom)
    }
}
