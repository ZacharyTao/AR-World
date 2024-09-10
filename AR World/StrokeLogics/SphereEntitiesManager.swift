//
//  SphereEntitiesManager.swift
//  AR World
//
//  Created by Zachary Tao on 9/7/24.
//

import RealityKit
import SwiftUI

enum StrokeColor: String {
    case red = "red"
    case green = "green"
    case blue = "blue"
    case white = "white"
    case black = "black"
}

class SphereEntitiesManager {

    static private let defaultSphereRadius: Float = 0.005

    static private var redReferenceSphereEntity: Entity = {
        return createSphereEntity(color: .red, radius: defaultSphereRadius)
    }()

    static private var greenReferenceSphereEntity: Entity = {
        return createSphereEntity(color: .green, radius: defaultSphereRadius)
    }()

    static private var blueReferenceSphereEntity: Entity = {
        return createSphereEntity(color: .blue, radius: defaultSphereRadius)
    }()

    static private var whiteReferenceSphereEntity: Entity = {
        return createSphereEntity(color: .white, radius: defaultSphereRadius)
    }()

    static private var blackReferenceSphereEntity: Entity = {
        return createSphereEntity(color: .black, radius: defaultSphereRadius)
    }()

    static private func createSphereEntity(color: UIColor, radius: Float) -> Entity {
        let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [UnlitMaterial(color: color)])
        return sphere
    }

    static func getReferenceSphereEntity(forStrokeColor color: StrokeColor, withRadius radius: Float = defaultSphereRadius) -> Entity {
        switch color {
        case .red:
            return createSphereEntity(color: .red, radius: radius)
        case .green:
            return createSphereEntity(color: .green, radius: radius)
        case .blue:
            return createSphereEntity(color: .blue, radius: radius)
        case .white:
            return createSphereEntity(color: .white, radius: radius)
        case .black:
            return createSphereEntity(color: .black, radius: radius)
        }
    }
}
