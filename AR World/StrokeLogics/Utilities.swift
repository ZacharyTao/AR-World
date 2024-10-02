//
//  Utilities.swift
//  AR World
//
//  Created by Zachary Tao on 9/7/24.
//

import ARKit
import RealityKit

// Gets the real-world position of the touch point at a specified distance from the camera in ARView
func getPosition(ofPoint point: CGPoint,
                 atDistanceFromCamera distance: Float,
                 inView view: ARView) -> SIMD3<Float>? {
    // Get the current camera position
    let cameraPosition = view.cameraTransform.translation
    // Get the direction from the camera to the 2D point on the screen
    guard let directionOfPoint =  view.ray(through: point)?.direction else { return nil }

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
    //
    for index in 0...((numberOfCirclesToCreate > 1) ? (numberOfCirclesToCreate - 1) : numberOfCirclesToCreate) {
        let position = point1 + (vectorBANormalized * (Float(index) * spacing))
        positions.append(position)
    }
    return positions
}

// Function to return dynamic size based on device type
func isIPhone() -> Bool {
    UIDevice.current.userInterfaceIdiom == .phone
}
