//
//  RenderView+Observer.swift
//  SolasApp
//
//  Created by Jeffrey Porter on 5/21/22.
//

import SwiftUI

extension RenderView {
    class Observer: ObservableObject {
        @Published var image: NSImage?
        @Published var width = 800
        @Published var height = 400
    }
    
    func renderGradiant() async {
        let image = pathTracer.gradiant(width: observer.width, height: observer.height)
        
        await MainActor.run {
            observer.image = image
        }
    }
    
    func renderSingle() async {
        
    }
}
