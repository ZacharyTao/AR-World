//
//  BrushMaterial.swift
//  AR World
//
//  Created by Zachary Tao on 2/5/25.
//

import SwiftUI
import RealityKit

enum BrushMaterial: String, Codable, CaseIterable {
    case basic
    case realistic
    case metallic

    func getMaterial(color: UIColor) -> RealityKit.Material {
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
