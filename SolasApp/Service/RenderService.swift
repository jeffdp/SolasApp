//  Copyright © 2022 Jeff Porter. All rights reserved.


import SwiftUI
import Combine
import CoreImage
import CoreImage.CIFilterBuiltins

enum RenderError: Error {
    case sampleOutOfRange
    case badImage
}

class RenderService: ObservableObject {
    @Published var image: NSImage?
    @Published var renderProgress: Float?
    
    private let pathTracer = PathTracer()
    private var cancellables = Set<AnyCancellable>()
    
    @MainActor
    func render(settings: Settings) async throws {
        print("main (render(settings:): \(Thread.isMainThread)")
        
        let image: NSImage
        
        renderProgress = 0
        NotificationCenter.default.publisher(for: PathTracer.progressNotification)
            .compactMap{$0.object as? Float}
            .receive(on: RunLoop.main)
            .sink() { [weak self] progress in
                self?.renderProgress = progress
            }
            .store(in: &cancellables)
        
        switch settings.selectedRenderer {
        case .testGradient:
            image = try await renderGradient(settings: settings)
        case .single:
            image =  try await renderSingle(settings: settings)
        case .async:
            image =  try await renderSimpleAsync(settings: settings)
        case .task:
            image =  try await renderTaskGroup(settings: settings)
        }

        // Would be false if not for @MainActor above
        print("main (render(settings:) after render: \(Thread.isMainThread)")

        // Render progress is nil once the render completes
        renderProgress = nil
        self.image = image
    }
    
    // MARK: - Internal methods
    
    private func denoise(_ image: NSImage) -> NSImage {
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!

        let context = CIContext()
        let currentFilter = CIFilter.noiseReduction()
        currentFilter.inputImage = CIImage(cgImage: cgImage)
        currentFilter.noiseLevel = 5
        currentFilter.sharpness = 10

        guard let outputImage = currentFilter.outputImage,
              let cgimg = context.createCGImage(outputImage, from: outputImage.extent) else {
            print("Noise reduction failed")
            return image
        }

       return NSImage(cgImage: cgimg, size: image.size)
    }
    
    private func renderGradient(settings: Settings) async throws -> NSImage {
        return try await pathTracer.renderGradient(width: settings.width, height: settings.height)
    }
    
    private func renderSingle(settings: Settings) async throws -> NSImage {
        print("main (renderSingle(settings:): \(Thread.isMainThread)")

        let samples = Int(settings.numberOfSamples) ?? 1
        
        return try await pathTracer.renderSingle(scene: settings.selectedScene,
                                                 width: settings.width,
                                                 height: settings.height,
                                                 numberOfSamples: samples)
    }
    
    private func renderSimpleAsync(settings: Settings) async throws -> NSImage {
        let samples = Int(settings.numberOfSamples) ?? 1

        return try await pathTracer.renderSimpleAsync(scene: settings.selectedScene,
                                                      width: settings.width,
                                                      height: settings.height,
                                                      numberOfSamples: samples)
    }

    private  func renderTaskGroup(settings: Settings) async throws -> NSImage {
        let samples = Int(settings.numberOfSamples) ?? 1

        return try await pathTracer.renderTaskGroup(scene: settings.selectedScene,
                                                    width: settings.width,
                                                    height: settings.height,
                                                    numberOfSamples: samples)
    }
}
