//
//  Utilities.swift
//  AR World
//
//  Created by Zachary Tao on 9/7/24.
//

import ARKit
import RealityKit

// Get the current position of the camera in ARView
func getCameraPosition(in view: ARView) -> SIMD3<Float>? {
    guard let lastFrame = view.session.currentFrame else {
        return nil
    }
    
    // Extract the camera position from the transform matrix
    let cameraTransform = lastFrame.camera.transform
    let cameraPosition = SIMD3<Float>(cameraTransform.columns.3.x,
                                      cameraTransform.columns.3.y,
                                      cameraTransform.columns.3.z)
    
    return cameraPosition
}


// Gets the real-world position of the touch point at a specified distance from the camera in ARView
func getPosition(ofPoint point: CGPoint,
                 atDistanceFromCamera distance: Float,
                 inView view: ARView) -> SIMD3<Float>? {
    // Get the current camera position
    guard let cameraPosition = getCameraPosition(in: view) else {
        return nil
    }
    
    // Get the direction from the camera to the 2D point on the screen
    guard let directionOfPoint = getDirection(for: point, in: view)?.normalized() else {
        return nil
    }
    
    // Calculate the real-world position of the touch point at the specified distance
    return (directionOfPoint * distance) + cameraPosition
}

// Helper function to normalize SIMD3<Float>
extension SIMD3 where Scalar == Float {
    func normalized() -> SIMD3<Float> {
        let length = sqrt(x * x + y * y + z * z)
        return self / length
    }
}

// Converts a 2D screen point to a real-world direction in ARView
func getDirection(for point: CGPoint, in view: ARView) -> SIMD3<Float>? {
    if let raycastResult = view.raycast(from: point, allowing: .estimatedPlane, alignment: .any).first {
        let worldPosition = raycastResult.worldTransform.columns.3
        let cameraTransform = view.cameraTransform
        let direction = SIMD3<Float>(worldPosition.x - cameraTransform.translation.x,
                                     worldPosition.y - cameraTransform.translation.y,
                                     worldPosition.z - cameraTransform.translation.z)
        return direction
    }
    return nil
}

// Gets the positions of the points on the line between point1 and point2 with the given spacing
func getPositionsOnLineBetween(point1: SIMD3<Float>,
                               andPoint2 point2: SIMD3<Float>,
                               withSpacing spacing: Float) -> [SIMD3<Float>] {
    var positions: [SIMD3<Float>] = []
    // Calculate the distance between previous point and current point
    let distance = length(point2 - point1)
    let numberOfCirclesToCreate = Int(distance / spacing)

    // https://math.stackexchange.com/a/83419
    // Begin by creating a vector BA by subtracting A from B (A = previousPoint, B = currentPoint)
    let vectorBA = point2 - point1
    // Normalize vector BA by dividing it by its length
    let vectorBANormalized = normalize(vectorBA)
    // This new vector can now be scaled and added to A to find the point at the specified distance
    for i in 0...((numberOfCirclesToCreate > 1) ? (numberOfCirclesToCreate - 1) : numberOfCirclesToCreate) {
        let position = point1 + (vectorBANormalized * (Float(i) * spacing))
        positions.append(position)
    }
    return positions
}
