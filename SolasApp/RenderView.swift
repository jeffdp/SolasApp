//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

struct RenderView: View {
    let pathTracer = PathTracer()
    @State var image = NSImage(systemSymbolName: "cube", accessibilityDescription: nil)!
    
    init() {

    }
    
    func render() {
        self.image = pathTracer.trace(width: 800, height: 400)
    }
    
    var body: some View {
        VStack {
            Image(nsImage: image)
            .resizable(capInsets: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
                       resizingMode: .stretch)
            .scaledToFill()
            .cornerRadius(10)
            .padding(EdgeInsets(top: 50, leading: 0, bottom: 8, trailing: 0))

            Button(action: render) {
                Image(systemName: "goforward")
            }
        }
    }
}

#if DEBUG
struct RenderView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
