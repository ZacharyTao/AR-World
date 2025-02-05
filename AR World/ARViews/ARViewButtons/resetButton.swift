//
//  resetButton.swift
//  AR World
//
//  Created by Zachary Tao on 2/5/25.
//

import SwiftUI

extension ARMainView {
    var resetButton: some View {
        VStack {
            Spacer()
            Button{
                customARView.resetSession()
            } label: {
                Text("Cancel")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.red.opacity(0.7))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
            }
            .padding()
        }

    }
}
