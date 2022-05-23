//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI
import Combine

struct InspectorView: View {
    @ObservedObject var settings: Settings
    @ObservedObject var renderService: RenderService
    
    var body: some View {
        VStack {
            Form {
                Text("Details")
                    .font(.headline)
                
                Picker("Scene", selection: $settings.selectedScene) {
                    Text("Two Spheres").tag(RenderScene.twoSpheres)
                    Text("Four Spheres").tag(RenderScene.fourSpheres)
                    Text("Random Spheres").tag(RenderScene.randomSpheres)
                }
                
                Picker("Render Method", selection: $settings.selectedRenderer) {
                    Text("Test Gradient").tag(Renderer.testGradient)
                    Text("Single thread").tag(Renderer.single)
                    Text("Simple Async").tag(Renderer.async)
                    Text("Task Groups").tag(Renderer.task)
                }
            
                TextField("Number of samples", text: $settings.numberOfSamples)
                    .onReceive(Just(settings.numberOfSamples)) { newValue in
                        var filtered = newValue.filter { "0123456789".contains($0) }
                        if filtered == "0" { filtered = "1" }
                        if filtered != newValue {
                            self.settings.numberOfSamples = filtered
                        }
                }
            }
            
            Spacer()
            
            if let progress = renderService.renderProgress {
                ProgressView(value: progress)
                    .progressViewStyle(.linear)
            }
            
            Button(action: render) {
                Text("Render")
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(idealWidth: 300, maxWidth: 300, maxHeight: .infinity)
    }
    
    func render() {
        Task {
            try await renderService.render(settings: settings)
        }
    }
}
