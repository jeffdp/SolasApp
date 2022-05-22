//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

extension RenderView {
    enum Renderer: String, CaseIterable, Identifiable {
        case testGradient, single, async, task
        var id: Self { self }
    }
    
    class Observer: ObservableObject {
        @Published var image: NSImage?
    }
    
    func renderGradient() async throws -> NSImage {
        return try await pathTracer.renderGradient(width: settings.width, height: settings.height)
    }
    
    func renderSingle() async throws -> NSImage {
        guard let samples = Int(settings.numberOfSamples) else {
            // TODO: Throw something
            fatalError("How'd a non-number get here?")
        }
        
        return try await pathTracer.renderSingle(scene: settings.selectedScene,
                                                 width: settings.width,
                                                 height: settings.height,
                                                 numberOfSamples: samples)
    }
    
    func renderSimpleAsync() async throws -> NSImage {
        guard let samples = Int(settings.numberOfSamples) else {
            // TODO: Throw something
            fatalError("How'd a non-number get here?")
        }

        return try await pathTracer.renderSimpleAsync(scene: settings.selectedScene,
                                                      width: settings.width,
                                                      height: settings.height,
                                                      numberOfSamples: samples)
    }

    func renderTaskGroup() async throws -> NSImage {
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
