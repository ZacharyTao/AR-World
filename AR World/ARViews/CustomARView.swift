//
//  CustomARView.swift
//  AR World
//
//  Created by Zachary Tao on 9/13/24.
//

import RealityKit
import SwiftUI

class CustomARView: ARView{
    private var currentStroke: Stroke?
    private var previousPosition: SIMD3<Float>?
    var document : [Stroke] = []
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        startNewStroke(at: location)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        updateStroke(at: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishStroke()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        finishStroke()
    }
    
    private func startNewStroke(at location: CGPoint) {
        guard let targetPosition = getPosition(ofPoint: location, atDistanceFromCamera: 0.2, inView: self) else { return }
        previousPosition = targetPosition
        currentStroke = Stroke(at: targetPosition)

        scene.addAnchor(currentStroke!.anchor)
    }
    
    private func updateStroke(at location: CGPoint) {
        guard let targetPosition = getPosition(ofPoint: location, atDistanceFromCamera: 0.2, inView: self),
              let currentStroke = currentStroke,
              let previousPosition = previousPosition else { return }
        
        let distance = distance(targetPosition, previousPosition)
        if distance > 0.001 {
            currentStroke.updateStroke(at: targetPosition)
            updateMesh()
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
    
    private func updateMesh() {
        guard let currentStroke = currentStroke else { return }
        
        currentStroke.anchor.children.removeAll()
        
        do{
            let entity = try currentStroke.generateStrokeEntity()
            currentStroke.anchor.addChild(entity, preservingWorldTransform: true)

        }catch {
            print("Failed to generate mesh: \(error.localizedDescription)")
            return
        }
    }
}

