//
//  ARViewContainer.swift
//  AR World
//
//  Created by Zachary Tao on 9/10/24.
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    var customARView: CustomARView
    func makeUIView(context: Context) -> ARView {
        customARView.session.delegate = context.coordinator
        customARView.renderOptions.insert([.disableHDR, .disableGroundingShadows, .disableAREnvironmentLighting, .disableDepthOfField, .disableCameraGrain, .disableMotionBlur, .disableAREnvironmentLighting])
        //customARView.environment.sceneUnderstanding.options.insert(.occlusion)
        let config = ARWorldTrackingConfiguration()
        if type(of: config).supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics = .personSegmentationWithDepth
        } else {
            print("This device doesn't support segmentation with depth")
        }
        customARView.session.run(config)
        return customARView
        
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, ARSessionDelegate {
        
        var parent: ARViewContainer
        
        init(_ parent: ARViewContainer) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            parent.customARView.updateCameraTrackingState(for: camera)
            print(camera.trackingState)
        }
    }
}


