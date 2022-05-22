//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI
import Combine

struct InspectorView: View {
    @ObservedObject var settings: Settings

    var body: some View {
        VStack {
            Form {
                Text("Details")
                Picker("Render Method", selection: $settings.selectedRenderer) {
                    Text("Test Gradient").tag(RenderView.Renderer.testGradient)
                    Text("Single thread").tag(RenderView.Renderer.single)
                    Text("Simple Async").tag(RenderView.Renderer.async)
                    Text("Task Groups").tag(RenderView.Renderer.task)
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
        }
        .padding()
        .frame(idealWidth: 250, maxWidth: 250, maxHeight: .infinity)
    }
}
