//
//  Stroke.swift
//  AR World
//
//  Created by Zachary Tao on 9/9/24.
//

import RealityKit
import ARKit

class StrokeAnchor{
    var color: StrokeColor
    let anchor: AnchorEntity
    let radius: Float
    
    
    init(color: StrokeColor = .white, at position: SIMD3<Float>, radius: Float = 0.005) {
        self.color = color
        self.anchor = AnchorEntity(world: position)
        self.radius = radius
    }
    
    func updateStroke(at position: SIMD3<Float>){
        let referenceSphereNode = SphereEntitiesManager.getReferenceSphereEntity(forStrokeColor: .white, withRadius: radius)
        let newSphereNode = referenceSphereNode.clone(recursive: false)
        newSphereNode.setPosition(position, relativeTo: nil)
        anchor.addChild(newSphereNode, preservingWorldTransform: true)
    }
    
    func updateStroke(at positions: [SIMD3<Float>]){
        for position in positions {
            updateStroke(at: position)
        }
    }
}
