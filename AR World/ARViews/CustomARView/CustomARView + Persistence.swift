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
    // MARK: - Persistence: Saving and Loading
    func loadExperience(mapData: Data) {

        guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: mapData) else {
            self.alertMessage = "Can't unarchive ARWorldMap from file data"
            return
        }
        print("Unarchived a world map : \(worldMap.anchors.count)")

        //        // Display the snapshot image stored in the world map to aid user in relocalizing.
        //        if let snapshotData = worldMap.snapshotAnchor?.imageData,
        //            let snapshot = UIImage(data: snapshotData) {
        //            self.arState.thumbnailImage = snapshot
        //        } else {
        //            print("No snapshot image in world map")
        //        }

        // Remove the snapshot anchor from the world map since we do not need it in the scene.
        // worldMap.anchors.removeAll(where: { $0 is SnapshotAnchor })

        let configuration = self.defaultConfiguration
        configuration.initialWorldMap = worldMap
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
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

//                guard let snapshotAnchor = SnapshotAnchor(capturing: self, snapshot: image) else {
//                    print("Failed to get snapshot anchor")
//                    return
//                }
//
//                map.anchors.append(snapshotAnchor)

                do {
                    let mapData = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                    let imageData = image.jpegData(compressionQuality: 0.7)
                    
                    context.insert(SavedMap(name: mapName, map: mapData, snapshot: imageData))
                    try context.save()
                } catch {
                    fatalError("Can't save map: \(error.localizedDescription)")
                }
            }
        }
    }
}
