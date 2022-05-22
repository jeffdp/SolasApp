//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

struct RenderView: View {
    @ObservedObject var settings: Settings
    @StateObject var observer = Observer()

    let pathTracer = PathTracer()

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
            let image: NSImage
            do {
                image = try await renderGradient()
            } catch let error {
                fatalError(error.localizedDescription)
            }
            observer.image = image
        }
        .onChange(of: settings.selectedRenderer) { newValue in
            Task { @MainActor in
                let image: NSImage
                switch newValue {
                case .testGradient:
                     image = try await renderGradient()
                case .single:
                    image = try await renderSingle()
                case .async:
                    image = try await renderSimpleAsync()
                case .task:
                    image = try await renderTaskGroup()
                }
                
                observer.image = image
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
