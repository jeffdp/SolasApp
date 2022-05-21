//  Copyright © 2022 Jeff Porter. All rights reserved.

import simd

class Camera {
    let lowerLeft: vec3
    let horizontal: vec3
    let vertical: vec3
    let origin: vec3

    init(lowerLeft: vec3, horizontal: vec3, vertical: vec3, origin: vec3) {
        self.lowerLeft = lowerLeft
        self.horizontal = horizontal
        self.vertical = vertical
        self.origin = origin
    }

    func ray(u: Float, v: Float) -> Ray {
        Ray(origin, lowerLeft + u*horizontal + v*vertical - origin)
    }
}
