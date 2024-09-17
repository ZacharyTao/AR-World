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
        
        customARView.renderOptions.insert([.disableHDR, .disableGroundingShadows, .disableAREnvironmentLighting, .disableDepthOfField, .disableCameraGrain, .disableMotionBlur, .disableAREnvironmentLighting])
        //customARView.environment.sceneUnderstanding.options.insert(.occlusion)
//        let config = ARWorldTrackingConfiguration()
//        if type(of: config).supportsFrameSemantics(.sceneDepth) {
//            config.frameSemantics = .personSegmentationWithDepth
//        } else {
//            print("This device doesn't support segmentation with depth")
//        }
//        customARView.session.run(config)
        
        return customARView
        
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
    }
}


