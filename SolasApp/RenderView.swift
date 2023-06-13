//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

struct RenderView: View {
    #if os(macOS)
    @Binding var image: NSImage?
    #elseif os(iOS)
    @Binding var image: UIImage?
    #endif

    var body: some View {
        ZStack(alignment: .center) {
            if let image = image {
                #if os(macOS)
                Image(nsImage: image)
                #elseif os(iOS)
                Image(uiImage: image)
                #endif
            } else {
                EmptyView()
            }
        }
    }
}
