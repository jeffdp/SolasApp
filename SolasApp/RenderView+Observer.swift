//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

extension RenderView {
    enum Renderer: String, CaseIterable, Identifiable {
        case testGradient, single, async, task
        var id: Self { self }
    }
    
    class Observer: ObservableObject {
        @Published var image: NSImage?
        @Published var width = 800
        @Published var height = 400
        
        @Published var selectedRenderer: Renderer = .single
    }
    
    func renderGradient() async throws -> NSImage {
        return try await pathTracer.renderGradient(width: observer.width, height: observer.height)
    }
    
    func renderSingle() async throws -> NSImage {
        return try await pathTracer.renderSingle(width: observer.width, height: observer.height)
    }
    
    func renderSimpleAsync() async throws -> NSImage{
        return try await pathTracer.renderSimpleAsync(width: observer.width, height: observer.height)
    }

    func renderTaskGroup() async throws -> NSImage{
        return try await pathTracer.renderTaskGroup(width: observer.width, height: observer.height)
    }
}
