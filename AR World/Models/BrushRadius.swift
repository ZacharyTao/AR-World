//
//  BrushRadius.swift
//  AR World
//
//  Created by Zachary Tao on 2/5/25.
//

import Foundation

enum BrushRadius: String, Codable, CaseIterable {
    case thin
    case medium
    case wide

    func getValue() -> Float {
        switch self {
        case .thin:
            return 0.002
        case .medium:
            return 0.006
        case .wide:
            return 0.010
        }
    }
}
