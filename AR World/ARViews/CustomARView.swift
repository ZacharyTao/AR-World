//
//  CustomARView.swift
//  AR World
//
//  Created by Zachary Tao on 9/13/24.
//

import RealityKit
import ARKit
import SwiftUI

class CustomARView: ARView, ObservableObject{
    private var currentStroke: Stroke?
    private var previousPosition: SIMD3<Float>?
    var selectedColor: Color = .white
    var selectedRadius: BrushRadius = .medium
    var selectedBrushMaterial: BrushMaterial = .basic
    var document : [Stroke] = []
    
    @Published var cameraTrackingMessageIsShowing = false
    @Published var trackingStateTitleLabel = ""
    @Published var trackingStateMessageLabel = ""
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        startNewStroke(at: location)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        updateStroke(at: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishStroke()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishStroke()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    private func startNewStroke(at location: CGPoint) {
        guard let targetPosition = getPosition(ofPoint: location, atDistanceFromCamera: 0.2, inView: self) else { return }
        previousPosition = targetPosition
        currentStroke = Stroke(color: UIColor(selectedColor), at: targetPosition, radius: selectedRadius.rawValue, material: selectedBrushMaterial)
        scene.addAnchor(currentStroke!.anchor)
    }
    
    private func updateStroke(at location: CGPoint) {
        guard let currentStroke = currentStroke,
              let previousPosition = previousPosition,
              let targetPosition = getPosition(ofPoint: location, atDistanceFromCamera: 0.2, inView: self) else { return }
        
        let distance = distance(targetPosition, previousPosition)
        if distance > 0.0018 {
            // let positions = getPositionsOnLineBetween(point1: previousPosition, andPoint2: targetPosition, withSpacing: 0.001)
            //currentStroke.updateStroke(at: positions)
            currentStroke.updateStroke(at: targetPosition)
            print(distance)
        }
        self.previousPosition = targetPosition
    }
    
    private func finishStroke() {
        if let currentStroke{
            document.append(currentStroke)
        }
        currentStroke = nil
        previousPosition = nil
    }
    
    func undoLastStroke() {
        guard let lastStroke = document.popLast() else { return }
        lastStroke.anchor.removeFromParent()
    }
    
    func updateCameraTrackingState(for camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            cameraTrackingMessageIsShowing = false
            break
        case .limited(.initializing):
            // "Initializing AR session."
            cameraTrackingMessageIsShowing = true
            trackingStateTitleLabel = "Detecting world"
            trackingStateMessageLabel = "Move your device around slowly"
        case .limited(.relocalizing):
            cameraTrackingMessageIsShowing = true
            trackingStateTitleLabel = "Relocolizing world"
            trackingStateMessageLabel = "Move back to the previous location"
        case .limited(.excessiveMotion):
            cameraTrackingMessageIsShowing = true
            trackingStateTitleLabel = "Too much movement"
            trackingStateMessageLabel = "Move your device more slowly"
        case .limited(.insufficientFeatures):
            cameraTrackingMessageIsShowing = true
            trackingStateTitleLabel = "Not enough detail"
            trackingStateMessageLabel = "Move around or find a better lit place"
        case .normal:
            cameraTrackingMessageIsShowing = false
        default:
            cameraTrackingMessageIsShowing = false
        }
    }
    
}

