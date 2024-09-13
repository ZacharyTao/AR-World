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
    let sphereEntitiesManager = SphereEntitiesManager()
    
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
              let currentStroke = currentStroke else { return }
        
        let distance = distance(targetPosition, previousPosition ?? targetPosition)
        if distance > 0.005 {
            currentStroke.updateStroke(at: targetPosition)
            updateMesh()
        }
    }
    
    private func finishStroke() {
        updateMesh()
        if let currentStroke{
            document.append(currentStroke)
        }
        currentStroke = nil
        previousPosition = nil
    }
    
    private func updateMesh() {
         guard let currentStroke = currentStroke,
               currentStroke.points.count >= 2 else { return }
         
         currentStroke.anchor.children.removeAll()
         
        guard let mesh = currentStroke.generateTubeMesh(from: currentStroke.points, radius: 0.005, segments: 8) else {
             print("Failed to generate mesh")
             return
         }
         
         let entity = ModelEntity(mesh: mesh, materials: [UnlitMaterial(color: .white)])
        currentStroke.anchor.addChild(entity, preservingWorldTransform: true)
     }
    

}
