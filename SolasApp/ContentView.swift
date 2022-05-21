//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

struct ContentView: View {
    var body: some View {
        RenderView()
            .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity,
                   minHeight: nil, idealHeight: nil, maxHeight: .infinity,
                   alignment: .center)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
