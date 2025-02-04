//
//  DownsizedImageView.swift
//  AR World
//
//  Created by Zachary Tao on 1/31/25.
//

import SwiftUI

struct DownsizedImageView<Content: View>: View {
    var image: UIImage?
    var size: CGSize
    @ViewBuilder var content: (Image) -> Content
    @State private var downsizedImageView: Image?

    var body: some View {
        ZStack {
            if let downsizedImageView {
                content(downsizedImageView)
            }
        }
        .onAppear {
            guard downsizedImageView == nil else { return }
            createDownsizedImage(image)
        }
        .onChange(of: image) { oldValue, newValue in
            guard oldValue != newValue else { return }
            createDownsizedImage(newValue)
        }
    }

    private func createDownsizedImage(_ image: UIImage?) {
        guard let image else { return }
        let aspectSize = image.size.aspectFit(size)

        Task.detached(priority: .high) {
            let renderer = UIGraphicsImageRenderer(size: aspectSize)
            let resizedImage = renderer.image { _ in
                image.draw(in: .init(origin: .zero, size: aspectSize))
            }

            await MainActor.run {
                downsizedImageView = .init(uiImage: resizedImage)
            }
        }
    }
}

extension CGSize {
    func aspectFit(_ to: CGSize) -> CGSize {
        let scaleX = to.width / self.width
        let scaleY = to.height / self.height

        let aspectRatio = min(scaleX, scaleY)
        return .init(width: aspectRatio * width, height: aspectRatio * height)
    }
}
