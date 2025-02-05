//
//  CustomARView + Session.swift
//  AR World
//
//  Created by Zachary Tao on 1/29/25.
//

import SwiftUI
import RealityKit
import ARKit

extension CustomARView: ARSessionDelegate {

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        if let currentFrame = session.currentFrame {
            updateSessionInfoLabel(for: currentFrame, trackingState: camera.trackingState)
        }
    }

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Enable Save button only when the mapping status is good and an object has been placed
        switch frame.worldMappingStatus {
        case .extending, .mapped:
            isSaveButtonEnabled = !document.isEmpty
        default:
            isSaveButtonEnabled = false
        }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }

    private func updateSessionInfoLabel(
        for frame: ARFrame,
        trackingState: ARCamera.TrackingState
    ) {
        var message = ""
        isThumbnailImageHidden = true

        switch trackingState {
        case .normal:
            if document.isEmpty {
                withAnimation { message = "Start drawing by tapping on the screen" }
            }

        case .limited(.relocalizing):
            isThumbnailImageHidden = false
            withAnimation { message = "Move your device to the location shown in the image." }
        default:
            message = ""
        }

        sessionInfoLabel = message
    }
}
