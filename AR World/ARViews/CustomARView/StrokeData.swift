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
    var radius: Float
    var points: [Vector3]
    var material: BrushMaterial
    var anchorName: String

    init(color: ColorData, radius: Float, points: [Vector3], material: BrushMaterial, anchorName: String) {
        self.color = color
        self.radius = radius
        self.points = points
        self.material = material
        self.anchorName = anchorName
    }
}
