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

        if isSavingMap {
            switch frame.worldMappingStatus {
            case .extending, .mapped:
                isSaveButtonEnabled = true
                sessionInfoLabel = "Tap the save button to capture and save the current map."
            default:
                isSaveButtonEnabled = false
                sessionInfoLabel = "Move around to map the environment and enable saving."
            }
        }

    }

    private func updateSessionInfoLabel(
        for frame: ARFrame,
        trackingState: ARCamera.TrackingState
    ) {
        isLoadingMap = false
        var message = ""

        switch trackingState {
        case .normal:
            if document.isEmpty {
                message = "Start drawing by tapping on the screen"
            }
        case .limited(.relocalizing):
            isLoadingMap = true
            message = "Move your device to the location shown in the image."
        default:
            message = ""
        }
        sessionInfoLabel = message
    }
}
