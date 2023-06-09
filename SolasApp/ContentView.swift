//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

enum Renderer: String, CaseIterable, Identifiable {
    case testGradient, single, async, task
    var id: Self { self }
}

class Settings: ObservableObject {
    @Published var selectedScene: RenderScene = .fourSpheres
    @Published var selectedRenderer: Renderer = .single
    @Published var numberOfSamples = "1"
    @Published var width = 1200
    @Published var height = Int(1200.0 * 9.0 / 16.0)
}

struct ContentView: View {
    @StateObject var settings = Settings()
    @StateObject var renderService: RenderService = RenderService()
    
    var body: some View {
        HSplitView {
            RenderView(image: $renderService.image)
                .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity,
                       minHeight: nil, idealHeight: nil, maxHeight: .infinity,
                       alignment: .center)
                .padding()
            InspectorView(settings: settings, renderService: renderService)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
