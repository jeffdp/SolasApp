//  Copyright © 2022 Jeff Porter. All rights reserved.

import simd
import SwiftUI

class Camera {
    let lowerLeft: vec3
    let horizontal: vec3
    let vertical: vec3
    let origin: vec3
    let lensRadius: Float
    
    init(lowerLeft: vec3, horizontal: vec3, vertical: vec3, origin: vec3, lensRadius: Float = 1.0) {
        self.lowerLeft = lowerLeft
        self.horizontal = horizontal
        self.vertical = vertical
        self.origin = origin
        self.lensRadius = lensRadius
    }
    
    convenience init(lookFrom: vec3, lookAt: vec3, vertical: vec3, vfov: Float, aspect: Float, aperture: Float, focusDist: Float) {
        let theta = vfov * .pi / 180.0
        let h = tan(theta/2)
        let viewportHeight = 2.0 * h
        let viewportWidth = aspect * viewportHeight

        let w = normalize(lookFrom - lookAt)
        let u = normalize(cross(vertical, w))
        let v = cross(w, u);

        let origin = lookFrom
        let horizontal = focusDist * viewportWidth * u
        let vertical = focusDist * viewportHeight * v
        let lowerLeft = origin - horizontal/2 - vertical/2 - focusDist*w

        let lensRadius = aperture / 2
        
        self.init(lowerLeft: lowerLeft, horizontal: horizontal, vertical: vertical, origin: origin, lensRadius: lensRadius)
    }

    func ray(u: Float, v: Float) -> Ray {
        Ray(origin, lowerLeft + u*horizontal + v*vertical - origin)
    }
}
