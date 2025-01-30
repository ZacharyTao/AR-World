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
        customARView.renderOptions.insert([
            .disableHDR,
            .disableGroundingShadows,
            .disableAREnvironmentLighting,
            .disableDepthOfField,
            .disableCameraGrain,
            .disableMotionBlur,
            .disableAREnvironmentLighting])

        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.goal = .tracking
        coachingOverlay.session = customARView.session
        coachingOverlay.setActive(true, animated: true)
        customARView.addSubview(coachingOverlay)

        customARView.session.delegate = customARView.self

        customARView.session.run(customARView.defaultConfiguration)
        return customARView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
    }
}
