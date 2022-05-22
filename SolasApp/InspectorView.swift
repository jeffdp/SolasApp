//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

struct InspectorView: View {
    @Binding var selectedRenderer: RenderView.Renderer

    var body: some View {
        VStack {
            Text("Details")
            Picker("Render Method", selection: $selectedRenderer) {
                Text("Test Gradient").tag(RenderView.Renderer.testGradient)
                Text("Single thread").tag(RenderView.Renderer.single)
                Text("Simple Async").tag(RenderView.Renderer.async)
                Text("Task Groups").tag(RenderView.Renderer.task)
            }
            
            Spacer()
        }
        .padding()
        .frame(idealWidth: 250, maxWidth: 250, maxHeight: .infinity)
    }
}
