//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

struct ContentView: View {
    @State var selectedRenderer: RenderView.Renderer = .testGradient
    
    var body: some View {
        HSplitView {
            RenderView(selectedRenderer: $selectedRenderer)
                .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity,
                       minHeight: nil, idealHeight: nil, maxHeight: .infinity,
                       alignment: .center)
                .padding()
            InspectorView(selectedRenderer: $selectedRenderer)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
