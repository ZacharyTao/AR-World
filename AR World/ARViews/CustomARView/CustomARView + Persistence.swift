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

extension CustomARView {
    // MARK: - Persistence: Saving and Loading

    func loadExperience(mapID: String) {

        guard let data = storedData.data(forKey: mapID) else {
            self.alertMessage = "No map data found"
            return
        }

        guard let worldMap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else {
            self.alertMessage = "Can't unarchive ARWorldMap from file data"
            return
        }

        //        // Display the snapshot image stored in the world map to aid user in relocalizing.
        //        if let snapshotData = worldMap.snapshotAnchor?.imageData,
        //            let snapshot = UIImage(data: snapshotData) {
        //            self.arState.thumbnailImage = snapshot
        //        } else {
        //            print("No snapshot image in world map")
        //        }

        // Remove the snapshot anchor from the world map since we do not need it in the scene.
        worldMap.anchors.removeAll(where: { $0 is SnapshotAnchor })

        let configuration = self.defaultConfiguration
        configuration.initialWorldMap = worldMap
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func saveExperience(mapName: String) {
        self.session.getCurrentWorldMap { worldMap, _ in
            guard let map = worldMap else {
                self.alertMessage = "Unable to get current world map, please try again later."
                return
            }

            // Add a snapshot image indicating where the map was captured.

            self.snapshot(saveToHDR: false) { image in
                guard let image = image else {
                    print("Failed to take snapshot")
                    return
                }

                guard let snapshotAnchor = SnapshotAnchor(capturing: self, snapshot: image) else {
                    print("Failed to get snapshot anchor")
                    return
                }

                map.anchors.append(snapshotAnchor)

                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)

                    if self.storedData.object(forKey: "map/\(mapName)") == nil {
                        self.storedData.set(data, forKey: "map/\(mapName)")
                    } else {
                        var counter = 1
                        while true {
                            let newKey = "map/\(mapName) \(counter)"
                            if self.storedData.object(forKey: newKey) == nil {
                                self.storedData.set(data, forKey: newKey)
                                break
                            }
                            counter += 1
                        }
                    }
                } catch {
                    fatalError("Can't save map: \(error.localizedDescription)")
                }
            }
        }
    }
}
