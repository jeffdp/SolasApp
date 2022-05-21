//  Copyright © 2022 Jeff Porter. All rights reserved.

import simd

struct Ray {
    private let a: vec3
    private let b: vec3

    var origin: vec3 {
        return a
    }

    var direction: vec3 {
        return b
    }

    init(_ a: vec3, _ b: vec3) {
        self.a = a
        self.b = b
    }

    func point(at t: Float) -> vec3 {
        a + t*b
    }
    
    static func randomInUnitSphere() -> vec3 {
        var p = vec3()
        repeat {
            let x = Float.random(in: 0...1)
            let y = Float.random(in: 0...1)
            let z = Float.random(in: 0...1)
            p = 2.0 * vec3(x, y, z) - vec3(1, 1, 1)
        } while p.length * p.length >= 1.0

        return p
    }
}
