//
//  SavedMap.swift
//  AR World
//
//  Created by Zachary Tao on 1/31/25.
//

import SwiftData
import SwiftUI

@Model
final class SavedMap {
    @Attribute(.unique) var name: String
    @Attribute(.externalStorage) var map: Data
    @Attribute(.externalStorage) var snapshot: Data?
    @Attribute(.externalStorage) var strokes: [StrokeData]

    init(name: String, map: Data, snapshot: Data?, strokes: [StrokeData]) {
        self.name = name
        self.map = map
        self.snapshot = snapshot
        self.strokes = strokes
    }
}

