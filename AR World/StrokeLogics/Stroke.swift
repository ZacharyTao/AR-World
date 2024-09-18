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
    var material: BrushMaterial
    
    
    init(color: UIColor, at position: SIMD3<Float>, radius: Float, material: BrushMaterial) {
        self.color = color
        self.anchor = AnchorEntity(world: position)
        self.radius = radius
        self.material = material
    }
    
    func updateStroke(at position: SIMD3<Float>){
        points.append(position)
    }
    
    @MainActor
    func generateStrokeEntity(segments: Int = 8) throws -> ModelEntity{
        let tubeMaterial : Material
        
        switch material {
        case .basic:
            tubeMaterial = UnlitMaterial(color: color)
        case .realistic:
            tubeMaterial = SimpleMaterial(color: color, roughness: 0.8, isMetallic: true)
        case .metallic:
            tubeMaterial = SimpleMaterial(color: color, isMetallic: true)
        }
        if points.count <= 3{
            return ModelEntity()
        }
        
        let tubeMesh = try generateTubeMesh(segments: segments)
        let tubeEntity = ModelEntity(mesh: tubeMesh, materials: [tubeMaterial])
                
        let startSphereEntity = ModelEntity(mesh: .generateSphere(radius: radius), materials: [tubeMaterial])
        startSphereEntity.position = points.first!
        
        let endSphereEntity = startSphereEntity.clone(recursive: false)
        endSphereEntity.position = points.last!
        
        let parentEntity = ModelEntity()
        parentEntity.addChild(tubeEntity)
        parentEntity.addChild(startSphereEntity)
        parentEntity.addChild(endSphereEntity)
        
        return parentEntity
    }
    
    @MainActor
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

enum BrushRadius: Float{
    case thin = 0.002
    case medium = 0.006
    case wide = 0.010
}

enum BrushMaterial{
    case basic
    case realistic
    case metallic
}
