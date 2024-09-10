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
    private var currentFingerLocation: CGPoint?
    private var currentStroke: StrokeAnchor?
    private var previousPoint: SIMD3<Float>?
    
    override init() {
        super.init()
    }
    
    @objc func didPanItem(panGesture: ImmediatePanGesture) {
        guard let arView = self.arView else { return }
        
        switch panGesture.state {
        case .began:
            currentFingerLocation = panGesture.location(in: arView)
        case .changed:
            currentFingerLocation = panGesture.location(in: arView)
        default:
            currentFingerLocation = nil
            currentStroke = nil
            previousPoint = nil
            break
        }
    }
    var count = 0

    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let arView = self.arView, let currentFingerLocation = currentFingerLocation else { return }
        guard let targetPosition = getPosition(ofPoint: currentFingerLocation, atDistanceFromCamera: 0.2, inView: arView) else { return }
        if let currentStroke, let previousPoint{
            let distance = distance(targetPosition, previousPoint)
            if distance > 0.00104 {
                currentStroke.updateStroke(at: targetPosition)
                print("draw \(count)")
                count = count + 1
                let positions = getPositionsOnLineBetween(point1: previousPoint, andPoint2: targetPosition, withSpacing: 0.001)
                currentStroke.updateStroke(at: positions)
                count += positions.count
                self.previousPoint = targetPosition
            }
        }else{
            currentStroke = StrokeAnchor(at: targetPosition)
            arView.scene.addAnchor(currentStroke!.anchor)
            previousPoint = targetPosition
        }
    }
}
