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
    @Published var image: OSImage?
    @Published var renderProgress: Float?
    @Published var renderTime = ""
    
    private let pathTracer = PathTracer()
    private var cancellables = Set<AnyCancellable>()
    
    @MainActor
    func render(settings: Settings) async throws {
        let image: OSImage

        renderProgress = 0
        NotificationCenter.default.publisher(for: PathTracer.progressNotification)
            .compactMap{$0.object as? Float}
            .receive(on: RunLoop.main)
            .sink() { [weak self] progress in
                self?.renderProgress = progress
            }
            .store(in: &cancellables)

        let startTime = Date()
        defer {
            let interval = Date().timeIntervalSince(startTime)
            renderTime = "\(interval.rounded()) seconds"
        }

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

        // Render progress is nil once the render completes
        renderProgress = nil
        self.image = image
    }
    
    // MARK: - Internal methods
    
    private func denoise(_ image: OSImage) -> OSImage {
        #if os(macOS)
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
//        let cgImage = image.cgImage( : nil, context: nil, hints: nil)!
        #elseif os(iOS)
        let cgImage = image.cgImage!
        #endif

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

        #if os(macOS)
        return OSImage(cgImage: cgimg, size: image.size)
        #elseif os(iOS)
        return OSImage(cgImage: cgimg)
        #endif
    }
    
    private func renderGradient(settings: Settings) async throws -> OSImage {
        return try await pathTracer.renderGradient(width: settings.width, height: settings.height)
    }
    
    private func renderSingle(settings: Settings) async throws -> OSImage {
        let samples = Int(settings.numberOfSamples) ?? 1
        
        return try await pathTracer.renderSingle(scene: settings.selectedScene,
                                                 width: settings.width,
                                                 height: settings.height,
                                                 numberOfSamples: samples)
    }
    
    private func renderSimpleAsync(settings: Settings) async throws -> OSImage {
        let samples = Int(settings.numberOfSamples) ?? 1

        return try await pathTracer.renderSimpleAsync(scene: settings.selectedScene,
                                                      width: settings.width,
                                                      height: settings.height,
                                                      numberOfSamples: samples)
    }

    private  func renderTaskGroup(settings: Settings) async throws -> OSImage {
        let samples = Int(settings.numberOfSamples) ?? 1

        return try await pathTracer.renderTaskGroup(scene: settings.selectedScene,
                                                    width: settings.width,
                                                    height: settings.height,
                                                    numberOfSamples: samples)
    }
}
