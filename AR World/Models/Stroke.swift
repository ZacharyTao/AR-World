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
    let arAnchor: ARAnchor
    let radius: Float
    var points: [SIMD3<Float>]
    var brushMaterial: BrushMaterial
    var currentEntity: ModelEntity?

    init(color: UIColor, anchorPosition: SIMD3<Float>, radius: Float, material: BrushMaterial) {
        self.color = color
        var transform = matrix_identity_float4x4
        transform.columns.3 = SIMD4<Float>(anchorPosition.x, anchorPosition.y, anchorPosition.z, 1.0)
        let strokeID = UUID().uuidString
        print("New Stroke ID: stroke_\(strokeID)")

        self.arAnchor = ARAnchor(name: "stroke_\(strokeID)", transform: transform)
        self.anchor = AnchorEntity(anchor: arAnchor)
        self.radius = radius
        self.points = []
        self.brushMaterial = material
    }

    init(strokeData: StrokeData, persistedAnchor: ARAnchor) {
        self.color = strokeData.color.uiColor
        self.arAnchor = persistedAnchor
        self.anchor = AnchorEntity(anchor: arAnchor)
        self.radius = strokeData.radius
        self.brushMaterial = strokeData.material
        self.points = strokeData.points.map { $0.simd }

        do {
            let entity = try generateStrokeEntity()
            anchor.addChild(entity)
            currentEntity = entity
        } catch {
            print("Failed to generate new stroke entity")
        }
    }

    func updateStroke(at position: SIMD3<Float>) {
        let anchorTransform = arAnchor.transform
        let inverseAnchorTransform = simd_inverse(anchorTransform)
        let worldPoint = SIMD4<Float>(position.x, position.y, position.z, 1.0)
        let localPoint4 = inverseAnchorTransform * worldPoint
        let localPoint = SIMD3<Float>(localPoint4.x, localPoint4.y, localPoint4.z)
        do {
            points.append(localPoint)
            if let currentEntity {
                anchor.removeChild(currentEntity)
            }
            let entity = try generateStrokeEntity()
            anchor.addChild(entity)
            currentEntity = entity
        } catch {
            print("Failed to generate mesh: \(error.localizedDescription)")
            return
        }
    }

    func generateStrokeEntity() throws -> ModelEntity {
        let startSphereEntity = ModelEntity(mesh: .generateSphere(radius: radius), materials: [brushMaterial.getMaterial(color: color)])
        let endSphereEntity = startSphereEntity.clone(recursive: false)
        let parentEntity = ModelEntity()

        if points.count < 1 {
            return ModelEntity()
        } else if points.count < 4 {
            startSphereEntity.position = points.first!
            return startSphereEntity
        }

        startSphereEntity.position = points.first!
        endSphereEntity.position = points.last!

        let tubeMesh = try generateTubeMesh()
        let tubeEntity = ModelEntity(mesh: tubeMesh, materials: [brushMaterial.getMaterial(color: color)])

        parentEntity.addChild(tubeEntity)
        parentEntity.addChild(startSphereEntity)
        parentEntity.addChild(endSphereEntity)

        return parentEntity
    }

    func generateTubeMesh() throws -> MeshResource {
        let segments = 16
        guard points.count >= 3 else {
            return try MeshResource.generate(from: [])
        }
        var vertices: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var uvs: [SIMD2<Float>] = []
        var indices: [UInt32] = []

        let pointCount = points.count

        for (index, point) in points.enumerated() {
            // Compute a smoothed tangent for the current point.
            let tangent: SIMD3<Float>
            if index > 0 && index < pointCount - 1 {
                let prevTangent = normalize(point - points[index - 1])
                let nextTangent = normalize(points[index + 1] - point)
                tangent = normalize(prevTangent + nextTangent)
            } else if index < pointCount - 1 {
                tangent = normalize(points[index + 1] - point)
            } else {
                tangent = normalize(point - points[index - 1])
            }

            // Use an alternate up vector if the tangent is nearly vertical.
            let referenceUp: SIMD3<Float> = abs(dot(tangent, SIMD3<Float>(0, 1, 0))) > 0.99
                ? SIMD3<Float>(1, 0, 0)
                : SIMD3<Float>(0, 1, 0)
            let right = normalize(cross(tangent, referenceUp))
            let localUp = normalize(cross(right, tangent))

            // Generate the circular cross-section.
            for j in 0..<segments {
                let angle = Float(j) / Float(segments) * 2 * .pi
                let offset = radius * (cos(angle) * right + sin(angle) * localUp)
                let circlePoint = point + offset
                let normal = normalize(offset) // Since offset is from the center.
                let uv = SIMD2<Float>(Float(index) / Float(pointCount - 1),
                                      Float(j) / Float(segments))

                vertices.append(circlePoint)
                normals.append(normal)
                uvs.append(uv)
            }
        }

        // Build indices connecting each ring.
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

extension Stroke {
    /// Converts a Stroke into a codable representation.
    func toStrokeData() -> StrokeData {
        return StrokeData(
            color: ColorData(self.color),
            radius: self.radius,
            points: self.points.map { Vector3($0) },
            material: self.brushMaterial,
            anchorName: self.arAnchor.name ?? ""
        )
    }
}
