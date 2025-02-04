//
//  Stroke.swift
//  AR World
//
//  Created by Zachary Tao on 9/9/24.
//

import RealityKit
import ARKit

class Stroke {
    var color: UIColor
    let anchor: AnchorEntity
    let radius: Float
    var points: [SIMD3<Float>]
    var brushMaterial: BrushMaterial

    init(color: UIColor, points: [SIMD3<Float>], radius: Float, material: BrushMaterial) {
        self.color = color
        self.anchor = AnchorEntity(world: points.first!)
        self.radius = radius
        self.points = points
        self.brushMaterial = material
    }

    func updateStroke(at position: SIMD3<Float>) {
        do {
            points.append(position)
            anchor.children.removeAll()
            let entity = try generateStrokeEntity()
            anchor.addChild(entity, preservingWorldTransform: true)
        } catch {
            print("Failed to generate mesh: \(error.localizedDescription)")
            return
        }
    }

    func generateStrokeEntity() throws -> ModelEntity {
        if points.count <= 3 {
            return ModelEntity()
        }

        let startSphereEntity = ModelEntity(mesh: .generateSphere(radius: radius), materials: [brushMaterial.getMaterial(color: color)])
        let endSphereEntity = startSphereEntity.clone(recursive: false)
        startSphereEntity.position = points.first!
        endSphereEntity.position = points.last!

        let tubeMesh = try generateTubeMesh()
        let tubeEntity = ModelEntity(mesh: tubeMesh, materials: [brushMaterial.getMaterial(color: color)])

        let parentEntity = ModelEntity()
        parentEntity.addChild(tubeEntity)
        parentEntity.addChild(startSphereEntity)
        parentEntity.addChild(endSphereEntity)

        return parentEntity
    }

    func generateTubeMesh() throws -> MeshResource {
        let segments = 8
        guard points.count >= 2 else { return try MeshResource.generate(from: []) }
        var vertices: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var uvs: [SIMD2<Float>] = []
        var indices: [UInt32] = []

        let pointCount = points.count

        for (index, point) in points.enumerated() {
            let nextPoint = index < pointCount - 1 ? points[index + 1] : point + (point - points[index - 1])
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
                let uv = SIMD2<Float>(Float(index) / Float(pointCount - 1), Float(j) / Float(segments))

                vertices.append(circlePoint)
                normals.append(normal)
                uvs.append(uv)
            }
        }

        for i in 0..<pointCount - 1 {
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

enum BrushRadius: String, Codable, CaseIterable {
    case thin
    case medium
    case wide

    func getValue() -> Float {
        switch self {
        case .thin:
            return 0.002
        case .medium:
            return 0.006
        case .wide:
            return 0.010
        }
    }
}

enum BrushMaterial: String, Codable, CaseIterable {
    case basic
    case realistic
    case metallic

    func getMaterial(color: UIColor) -> Material {
        switch self {
        case .basic:
            UnlitMaterial(color: color)
        case .realistic:
            SimpleMaterial(color: color, roughness: 0.8, isMetallic: true)
        case .metallic:
            SimpleMaterial(color: color, isMetallic: true)
        }
    }
}

extension Stroke {
    /// Converts a Stroke into a codable representation.
    func toStrokeData() -> StrokeData {
        return StrokeData(
            color: ColorData(self.color),
            radius: self.radius,
            points: self.points.map { Vector3($0) },
            material: self.brushMaterial
        )
    }

    /// Convenience initializer to create a Stroke from its data representation.
    convenience init(strokeData: StrokeData) {
        self.init(
            color: strokeData.color.uiColor,
            points: strokeData.points.map { $0.simd },
            radius: strokeData.radius,
            material: strokeData.material
        )

        // Regenerate the stroke’s mesh.
        do {
            let entity = try self.generateStrokeEntity()
            // Remove any children and add the new geometry.
            self.anchor.children.removeAll()
            self.anchor.addChild(entity, preservingWorldTransform: true)
        } catch {
            print("Error regenerating stroke entity: \(error)")
        }
    }
}
