//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

struct RenderView: View {
    @Binding var image: NSImage?
    
    var body: some View {
        ZStack(alignment: .center) {
            if let image = image {
                Image(nsImage: image)
                    .resizable(resizingMode: .stretch)
                    .scaledToFill()
            } else {
                EmptyView()
            }
        }
    }
}
