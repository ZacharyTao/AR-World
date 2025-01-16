//
//  ColorExtension.swift
//  AR World
//
//  Created by Zachary Tao on 1/16/25.
//

import SwiftUI

extension Color: @retroactive RawRepresentable {

    public init?(rawValue: String) {

        guard let data = Data(base64Encoded: rawValue) else {
            self = .black
            return
        }

        do {
            let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) ?? .black
            self = Color(color)
        } catch {
            self = .black
        }

    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: UIColor(self),
                                                        requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
             return ""
        }
    }
}
