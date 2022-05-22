//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

class Settings: ObservableObject {
    @Published var selectedRenderer: RenderView.Renderer = .testGradient
    @Published var numberOfSamples = "5"
    @Published var width = 800
    @Published var height = 400
}

struct ContentView: View {
    @StateObject var settings = Settings()
    
    var body: some View {
        HSplitView {
            RenderView(settings: settings)
                .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity,
                       minHeight: nil, idealHeight: nil, maxHeight: .infinity,
                       alignment: .center)
                .padding()
            InspectorView(settings: settings)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
