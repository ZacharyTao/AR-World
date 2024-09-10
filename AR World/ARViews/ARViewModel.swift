//
//  ARViewModel.swift
//  AR World
//
//  Created by Zachary Tao on 9/7/24.
//
import RealityKit
import SwiftUI

class ARViewModel: ObservableObject {
    @Published var isRelocalizingWorldMap = false
    private var currentColor: StrokeColor = .white
    @Published var currentTapPosition: CGPoint = .zero
    
    func undo() {
    }
    
    func changeColor() {
    }
    
    func save() {

    }
    
    func load() {

    }
}
