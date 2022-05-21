//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Solas")
        
        VStack {
            HStack {
                RenderView()
                    .frame(minWidth: nil, idealWidth: nil, maxWidth: .infinity, minHeight: nil, idealHeight: nil, maxHeight: .infinity, alignment: .top)
                    .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
