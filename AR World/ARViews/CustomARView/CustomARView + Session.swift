//
//  CustomARView + Session.swift
//  AR World
//
//  Created by Zachary Tao on 1/29/25.
//

import Foundation
import RealityKit
import ARKit

extension CustomARView: ARSessionDelegate {
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Enable Save button only when the mapping status is good and an object has been placed
        switch frame.worldMappingStatus {
        case .extending, .mapped:
            isSaveButtonEnabled = !document.isEmpty
        default:
            isSaveButtonEnabled = false
        }
    }
}
