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

    func loadStrokesOnCurrentMap(savedMap: SavedMap) {
        guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: savedMap.map) else {
            self.alertMessage = "Can't unarchive ARWorldMap from file data"
            return
        }

        // Find the center point of all anchors
        var centerPoint = SIMD3<Float>(0, 0, 0)
        var anchorCount = 0

        for savedAnchor in worldMap.anchors {
            if savedAnchor.name?.hasPrefix("stroke_") == true {
                centerPoint += SIMD3<Float>(savedAnchor.transform.columns.3.x,
                                          savedAnchor.transform.columns.3.y,
                                          savedAnchor.transform.columns.3.z)
                anchorCount += 1
            }
        }

        guard anchorCount > 0 else { return }
        centerPoint /= Float(anchorCount)

        let screenSize = UIScreen.main.bounds.size
        let screenCenter = CGPoint(x: screenSize.width / 2, y: screenSize.height / 2)
        let targetPosition = getPosition(ofPoint: screenCenter, atDistanceFromCamera: 0.5, inView: self) ?? cameraTransform.translation

        let translation = targetPosition - centerPoint

        var strokes: [Stroke] = []
        for savedAnchor in worldMap.anchors {
            if let savedAnchorName = savedAnchor.name,
               savedAnchorName.hasPrefix("stroke_"),
               let strokeData = savedMap.strokes.first(where: { $0.anchorName == savedAnchorName }) {
                // Create new transform with translated position
                var newTransform = savedAnchor.transform
                let currentPos = SIMD3<Float>(newTransform.columns.3.x,
                                            newTransform.columns.3.y,
                                            newTransform.columns.3.z)
                let newPos = currentPos + translation
                newTransform.columns.3 = SIMD4<Float>(newPos.x, newPos.y, newPos.z, 1.0)

                let newAnchor = ARAnchor(transform: newTransform)
                strokes.append(Stroke(strokeData: strokeData, persistedAnchor: newAnchor))
            }
        }

        for stroke in strokes {
            session.add(anchor: stroke.arAnchor)
            scene.addAnchor(stroke.anchor)
            document.append(stroke)
        }
    }

    func saveExperience(mapName: String, context: ModelContext) {
        for stroke in document {
            session.add(anchor: stroke.arAnchor)
        }

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
