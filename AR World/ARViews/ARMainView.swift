//
//  ARMainView.swift
//  AR World
//
//  Created by Zachary Tao on 9/7/24.
//

import SwiftUI
import RealityKit
import ARKit


struct ARMainView : View {
    @StateObject private var arViewModel = ARViewModel()
    
    var body: some View {
        ZStack{
            ARViewContainer().edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: arViewModel.undo) {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    
                    Spacer()
                    
                    Button(action: arViewModel.changeColor) {
                        Image(systemName: "paintpalette")
                    }
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    ARMainView()
}


