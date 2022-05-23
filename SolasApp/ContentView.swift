//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

enum Renderer: String, CaseIterable, Identifiable {
    case testGradient, single, async, task
    var id: Self { self }
}

class Settings: ObservableObject {
    @Published var selectedScene: RenderScene = .fourSquares
    @Published var selectedRenderer: Renderer = .testGradient
    @Published var numberOfSamples = "1"
    @Published var width = 800
    @Published var height = 400
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
