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

    init(name: String, map: Data, snapshot: Data?) {
        self.name = name
        self.map = map
        self.snapshot = snapshot
    }
}
