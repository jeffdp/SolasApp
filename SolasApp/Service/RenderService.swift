//  Copyright © 2022 Jeff Porter. All rights reserved.


import SwiftUI
import Combine

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
    
    private func renderGradient(settings: Settings) async throws -> NSImage {
        return try await pathTracer.renderGradient(width: settings.width, height: settings.height)
    }
    
    private func renderSingle(settings: Settings) async throws -> NSImage {
        print("main (renderSingle(settings:): \(Thread.isMainThread)")

        guard let samples = Int(settings.numberOfSamples) else {
            // TODO: Throw something
            fatalError("How'd a non-number get here?")
        }
        
        return try await pathTracer.renderSingle(scene: settings.selectedScene,
                                                 width: settings.width,
                                                 height: settings.height,
                                                 numberOfSamples: samples)
    }
    
    private func renderSimpleAsync(settings: Settings) async throws -> NSImage {
        guard let samples = Int(settings.numberOfSamples) else {
            // TODO: Throw something
            fatalError("How'd a non-number get here?")
        }

        return try await pathTracer.renderSimpleAsync(scene: settings.selectedScene,
                                                      width: settings.width,
                                                      height: settings.height,
                                                      numberOfSamples: samples)
    }

    private  func renderTaskGroup(settings: Settings) async throws -> NSImage {
        guard let samples = Int(settings.numberOfSamples) else {
            // TODO: Throw something
            fatalError("How'd a non-number get here?")
        }

        return try await pathTracer.renderTaskGroup(scene: settings.selectedScene,
                                                    width: settings.width,
                                                    height: settings.height,
                                                    numberOfSamples: samples)
    }
}
