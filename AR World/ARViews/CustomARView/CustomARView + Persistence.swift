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
    func loadExperience(savedMap: SavedMap) {
        guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: savedMap.map) else {
            self.alertMessage = "Can't unarchive ARWorldMap from file data"
            return
        }

        var strokes: [Stroke] = []
        for savedAnchor in worldMap.anchors {
            if let savedAnchorName = savedAnchor.name,
               savedAnchorName.hasPrefix("stroke_"),
               let strokeData = savedMap.strokes.first(where: { $0.anchorName == savedAnchorName }) {
                strokes.append(Stroke(strokeData: strokeData, persistedAnchor: savedAnchor))
            }
        }

        if let snapshotData = savedMap.snapshot,
            let snapshot = UIImage(data: snapshotData) {
            self.thumbnailImage = snapshot
        } else {
            print("No snapshot image in world map")
        }
        let configuration = self.defaultConfiguration

        configuration.initialWorldMap = worldMap
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        clearAllStrokes()

        for stroke in strokes {
            session.add(anchor: stroke.arAnchor)
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
