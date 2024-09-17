//
//  Stroke.swift
//  AR World
//
//  Created by Zachary Tao on 9/9/24.
//

import RealityKit
import ARKit

class Stroke{
    var color: UIColor
    let anchor: AnchorEntity
    let radius: Float
    var points: [SIMD3<Float>] = []
    
    
    init(color: UIColor, at position: SIMD3<Float>, radius: Float) {
        self.color = color
        self.anchor = AnchorEntity(world: position)
        self.radius = radius
    }
    
    func updateStroke(at position: SIMD3<Float>){
        points.append(position)
    }
    
    func generateStrokeEntity(segments: Int = 8) throws -> ModelEntity{
        let tubeMaterial = UnlitMaterial(color: color)
        if points.count <= 3{
            return ModelEntity()
        }
        
        let tubeMesh = try generateTubeMesh(segments: segments)
        let tubeEntity = ModelEntity(mesh: tubeMesh, materials: [tubeMaterial])
        
        let startSphereMesh = MeshResource.generateSphere(radius: radius)
        let endSphereMesh = MeshResource.generateSphere(radius: radius)
        
        let startSphereEntity = ModelEntity(mesh: startSphereMesh, materials: [tubeMaterial])
        startSphereEntity.position = points.first!
        
        let endSphereEntity = ModelEntity(mesh: endSphereMesh, materials: [tubeMaterial])
        endSphereEntity.position = points.last!
        
        let parentEntity = ModelEntity()
        parentEntity.addChild(tubeEntity)
        parentEntity.addChild(startSphereEntity)
        parentEntity.addChild(endSphereEntity)
        
        return parentEntity
    }
    
    
    func generateTubeMesh(segments: Int) throws -> MeshResource {
        guard points.count >= 2 else { return try MeshResource.generate(from: [])}
        var vertices: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var uvs: [SIMD2<Float>] = []
        var indices: [UInt32] = []
        
        for (i, point) in points.enumerated() {
            let nextPoint = i < points.count - 1 ? points[i + 1] : point + (point - points[i - 1])
            let direction = normalize(nextPoint - point)
            let up = SIMD3<Float>(0, 1, 0)
            let right = normalize(cross(direction, up))
            let realUp = normalize(cross(right, direction))
            
            for j in 0..<segments {
                let angle = Float(j) / Float(segments) * 2 * .pi
                let x = cos(angle)
                let y = sin(angle)
                let circlePoint = point + radius * (x * right + y * realUp)
                let normal = normalize(circlePoint - point)
                let uv = SIMD2<Float>(Float(i) / Float(points.count - 1), Float(j) / Float(segments))
                
                vertices.append(circlePoint)
                normals.append(normal)
                uvs.append(uv)
            }
        }
        
        for i in 0..<points.count - 1 {
            for j in 0..<segments {
                let nextJ = (j + 1) % segments
                let currentRow = i * segments
                let nextRow = (i + 1) * segments
                
                indices.append(contentsOf: [
                    UInt32(currentRow + j), UInt32(nextRow + j), UInt32(nextRow + nextJ),
                    UInt32(currentRow + j), UInt32(nextRow + nextJ), UInt32(currentRow + nextJ)
                ])
            }
        }
        
        var descriptor = MeshDescriptor()
        descriptor.positions = MeshBuffers.Positions(vertices)
        descriptor.normals = MeshBuffers.Normals(normals)
        descriptor.textureCoordinates = MeshBuffers.TextureCoordinates(uvs)
        descriptor.primitives = .triangles(indices)
        
        return try MeshResource.generate(from: [descriptor])
        
    }
    
}
