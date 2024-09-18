//
//  ColorPickerButton.swift
//  AR World
//
//  Created by Zachary Tao on 9/17/24.
//

import SwiftUI

extension ARMainView{
    var ColorPickerButton: some View{
        ColorPicker("", selection: $customARView.selectedColor, supportsOpacity: false)
            .labelsHidden()
            .frame(width: 30)
    }
}
