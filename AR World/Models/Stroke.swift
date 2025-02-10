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

        guard points.count >= 2 else {
            return try MeshResource.generate(from: [])
        }

        var vertices: [SIMD3<Float>] = []
        var normals: [SIMD3<Float>] = []
        var uvs: [SIMD2<Float>] = []
        var indices: [UInt32] = []

        // --- Setup Initial Frame ---
        let firstPoint = points[0]
        let secondPoint = points[1]
        var T = normalize(secondPoint - firstPoint)

        // Choose a reference up vector. If T is nearly vertical, use (1,0,0) instead.
        let referenceUp: SIMD3<Float> = abs(dot(T, SIMD3<Float>(0, 1, 0))) > 0.99 ? SIMD3<Float>(1, 0, 0) : SIMD3<Float>(0, 1, 0)

        // Compute two perpendicular vectors that form the initial plane for the cross-section.
        var frameX = normalize(cross(T, referenceUp))
        var frameY = normalize(cross(frameX, T))

        for i in 0..<points.count {
            let point = points[i]
            if i > 0 {
                let newT = normalize(point - points[i - 1])
                let dotProd = dot(T, newT)
                if dotProd < 0.9999 {
                    let rotationAxis = normalize(cross(T, newT))
                    let angle = acos(clamp(dot(T, newT), -1, 1))
                    frameX = rotate(frameX, angle: angle, axis: rotationAxis)
                    frameY = rotate(frameY, angle: angle, axis: rotationAxis)
                }
                T = newT
            }

            // For each point, generate a circle (ring) in the plane defined by frameX and frameY.
            for j in 0..<segments {
                let theta = (Float(j) / Float(segments)) * 2 * Float.pi
                let offset = radius * (cos(theta) * frameX + sin(theta) * frameY)
                let circlePoint = point + offset
                vertices.append(circlePoint)
                normals.append(normalize(offset))
                let uv = SIMD2<Float>(Float(i) / Float(points.count - 1),
                                      Float(j) / Float(segments))
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

extension Stroke {
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
