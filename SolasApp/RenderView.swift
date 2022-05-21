//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

struct RenderView: View {
    let pathTracer = PathTracer()
    @StateObject var observer = Observer()
    
    init() {

    }
    
    var body: some View {
        Group {
            if let image = observer.image {
                Image(nsImage: image)
                    .resizable(resizingMode: .stretch)
                    .scaledToFill()
            } else {
                ProgressView()
            }
        }
        .task {
            await renderGradiant()
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
