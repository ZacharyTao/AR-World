//
//  SnapshotAnchor.swift
//  AR World
//
//  Created by Zachary Tao on 1/29/25.
//

import ARKit
import RealityKit

class SnapshotAnchor: ARAnchor, @unchecked Sendable {

    let imageData: Data

    convenience init?(capturing view: ARView, snapshot: UIImage) {
        guard let frame = view.session.currentFrame else { return nil}

        guard let data = snapshot.jpegData(compressionQuality: 0.2) else {
            print("Failed to convert image to JPEG data")
            return nil
        }

        self.init(imageData: data, transform: frame.camera.transform)
    }

    init(imageData: Data, transform: float4x4) {
        self.imageData = imageData
        super.init(name: "snapshot", transform: transform)
    }

    required init(anchor: ARAnchor) {
        if let snapshotAnchor = anchor as? SnapshotAnchor {
            self.imageData = snapshotAnchor.imageData
        } else {
            self.imageData = Data()
        }
        super.init(anchor: anchor)
    }

    override class var supportsSecureCoding: Bool {
        return true
    }

    required init?(coder aDecoder: NSCoder) {
        if let snapshot = aDecoder.decodeObject(of: NSData.self, forKey: "snapshot") as? Data {
            self.imageData = snapshot
        } else {
            return nil
        }

        super.init(coder: aDecoder)
    }

    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(imageData, forKey: "snapshot")
    }
}
