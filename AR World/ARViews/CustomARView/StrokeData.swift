//
//  StrokeData.swift
//  AR World
//
//  Created by Zachary Tao on 2/2/25.
//

import SwiftData
import ARKit

@Model
final class StrokeData {
    var color: ColorData
    var startPosition: Vector3
    var radius: Float
    var points: [Vector3]
    var material: BrushMaterial

    init(color: ColorData, startPosition: Vector3, radius: Float, points: [Vector3], material: BrushMaterial) {
        self.color = color
        self.startPosition = startPosition
        self.radius = radius
        self.points = points
        self.material = material
    }
}
