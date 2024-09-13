//
//  ARCoordinator.swift
//  AR World
//
//  Created by Zachary Tao on 9/10/24.
//

import ARKit
import RealityKit
import Combine

final class ARCoordinator: NSObject, ARSessionDelegate {
    
    private var subscription: Set<AnyCancellable> = []
    
    weak var arView: ARView?
    private var currentStroke: Stroke?
    private var previousPosition: SIMD3<Float>?
    var document : [Stroke] = []
    
    override init() {
        super.init()
    }
    
    @objc func didPanItem(panGesture: ImmediatePanGesture) {
        guard let arView = self.arView else { return }
        
        switch panGesture.state {
        case .began:
            startNewStroke(at: panGesture.location(in: arView))
        case .changed:
            updateStroke(at: panGesture.location(in: arView))
        default:
            finishStroke()
            break
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
    }
    
    private func startNewStroke(at location: CGPoint) {
        guard let arView = self.arView,
              let targetPosition = getPosition(ofPoint: location, atDistanceFromCamera: 0.2, inView: arView) else { return }
        previousPosition = targetPosition
        currentStroke = Stroke(at: targetPosition)
        arView.scene.addAnchor(currentStroke!.anchor)
    }
    
    private func updateStroke(at location: CGPoint) {
        guard let arView = self.arView,
              let targetPosition = getPosition(ofPoint: location, atDistanceFromCamera: 0.2, inView: arView),
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
