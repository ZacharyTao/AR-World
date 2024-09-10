//
//  ARViewContainer.swift
//  AR World
//
//  Created by Zachary Tao on 9/10/24.
//

import SwiftUI
import RealityKit
import ARKit

extension ARMainView{
    struct ARViewContainer: UIViewRepresentable {
        func makeUIView(context: Context) -> ARView {
            let arView = ARView(frame: .zero)
            arView.addGestureRecognizer(ImmediatePanGesture(target: context.coordinator, action: #selector(ARCoordinator.didPanItem(panGesture:))))

            context.coordinator.arView = arView
            arView.session.delegate = context.coordinator
            arView.renderOptions.insert([.disableHDR, .disableGroundingShadows, .disableAREnvironmentLighting, .disableDepthOfField, .disableCameraGrain, .disableMotionBlur, .disableAREnvironmentLighting])

            return arView
        }
        
        func updateUIView(_ uiView: ARView, context: Context) {
        }
    
        
        func makeCoordinator() -> ARCoordinator {
            ARCoordinator()
        }
        
    }
}
