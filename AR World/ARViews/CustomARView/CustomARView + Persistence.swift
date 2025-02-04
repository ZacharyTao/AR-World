//
//  CustomARView + Persistence.swift
//  AR World
//
//  Created by Zachary Tao on 1/29/25.
//

import Foundation
import RealityKit
import ARKit
import SwiftUI
import SwiftData

extension CustomARView {
    func loadExperience(mapData: Data, strokeData: [StrokeData]) {
        guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: mapData) else {
            self.alertMessage = "Can't unarchive ARWorldMap from file data"
            return
        }
        print("Unarchived a world map : \(worldMap.anchors.count)")

        let strokes = strokeData.map { Stroke(strokeData: $0) }
        let configuration = self.defaultConfiguration

        configuration.initialWorldMap = worldMap
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        scene.anchors.removeAll()
        document.removeAll()

        for stroke in strokes {
            scene.addAnchor(stroke.anchor)
            document.append(stroke)
        }
    }

    func saveExperience(mapName: String, context: ModelContext) {
        self.session.getCurrentWorldMap { worldMap, _ in
            guard let map = worldMap else {
                self.alertMessage = "Unable to get current world map, please try again later."
                return
            }

            self.snapshot(saveToHDR: false) { image in
                guard let image = image else {
                    print("Failed to take snapshot")
                    return
                }

                do {
                    let mapData = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                    let imageData = image.jpegData(compressionQuality: 0.7)
                    let strokeData = self.document.map { $0.toStrokeData() }

                    context.insert(SavedMap(name: mapName, map: mapData, snapshot: imageData, strokes: strokeData))
                    try context.save()
                } catch {
                    fatalError("Can't save map: \(error.localizedDescription)")
                }
            }
        }
    }
}
