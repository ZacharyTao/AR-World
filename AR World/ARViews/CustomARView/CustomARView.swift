//
//  CustomARView.swift
//  AR World
//
//  Created by Zachary Tao on 9/13/24.
//

import RealityKit
import ARKit
import SwiftUI

@Observable
class CustomARView: ARView {
    private var currentStroke: Stroke?
    private var previousPosition: SIMD3<Float>?
    var isSaveButtonEnabled: Bool = false
    var alertMessage: String?

    var isLoadingMap = false
    var isSavingMap = false
    var isDrawingDisabled = false

    var thumbnailImage: UIImage?
    var sessionInfoLabel: String?

    @ObservationIgnored @AppStorage("selectedColor") var selectedColor: Color = .white
    @ObservationIgnored @AppStorage("selectedRadius") var selectedRadius: BrushRadius = .medium
    @ObservationIgnored @AppStorage("selectedBrushMaterial") var selectedBrushMaterial: BrushMaterial = .basic

    var document: [Stroke] = []

    var defaultConfiguration: ARWorldTrackingConfiguration {
        let config = ARWorldTrackingConfiguration()
        if type(of: config).supportsFrameSemantics(.sceneDepth) {
            config.frameSemantics = .personSegmentationWithDepth
        } else {
            print("This device doesn't support segmentation with depth")
        }
        return config
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isLoadingMap || isSavingMap || isDrawingDisabled {
            print("Touch disabled because \(isLoadingMap ? "loading map" : isSavingMap ? "saving map" : "drawing disabled")")
            return
        }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        startNewStroke(at: location)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isLoadingMap || isSavingMap || isDrawingDisabled {
            return
        }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        updateStroke(at: location)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isLoadingMap || isSavingMap || isDrawingDisabled {
            return
        }
        finishStroke()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isLoadingMap || isSavingMap || isDrawingDisabled {
            return
        }
        finishStroke()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func startNewStroke(at location: CGPoint) {
        guard let targetPosition = getPosition(ofPoint: location, atDistanceFromCamera: 0.2, inView: self)
        else { return }
        previousPosition = targetPosition
        let newStroke = Stroke(color: UIColor(selectedColor),
                               anchorPosition: targetPosition,
                               radius: selectedRadius.getValue(),
                               material: selectedBrushMaterial)
        newStroke.updateStroke(at: targetPosition)
        scene.addAnchor(newStroke.anchor)
        currentStroke = newStroke
    }

    private func updateStroke(at location: CGPoint) {
        guard let currentStroke = currentStroke,
              let previousPosition = previousPosition,
              let targetPosition = getPosition(ofPoint: location, atDistanceFromCamera: 0.2, inView: self)
        else { return }

        let dist = distance(targetPosition, previousPosition)
        let threshold = Float(0.001)

        // print("Distance: \(dist), Threshold: \(threshold), \(dist > threshold ? "✅" : "🟥")")

        if dist > threshold {
            currentStroke.updateStroke(at: targetPosition)
            self.previousPosition = targetPosition
        }
    }

    private func finishStroke() {
        if let currentStroke {
            document.append(currentStroke)
        }
        currentStroke = nil
        previousPosition = nil
    }

    func undoLastStroke() {
        guard let lastStroke = document.popLast() else { return }
        // lastStroke.anchor.removeFromParent()
        scene.removeAnchor(lastStroke.anchor)
        session.remove(anchor: lastStroke.arAnchor)
    }

    func clearAllStrokes() {
        while !document.isEmpty {
            undoLastStroke()
        }
    }
}

extension CustomARView {
    func pauseSession() {
        self.session.pause()
    }

    func resumeSession() {
        self.session.run(session.configuration ?? defaultConfiguration)
    }

    func resetSession() {
        self.session.run(defaultConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
}
