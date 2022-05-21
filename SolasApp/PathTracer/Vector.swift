//  Copyright © 2022 Jeff Porter. All rights reserved.

import simd

typealias vec3 = SIMD3<Float>

extension SIMD3 where Scalar == Float {
    var length: Float {
        sqrt(x*x + y*y + z*z)
    }

    func normalized() -> vec3 {
        return self / length
    }

    func reflect(_ n: vec3) -> vec3 {
        self - 2 * dot(self, n) * n
    }

    func refract(_ n: vec3, niOverNt: Float) -> vec3? {
        let uv = self.normalized()
        let dt = dot(uv, n)
        let discriminant = 1.0 - niOverNt * niOverNt * (1 - dt*dt)

        guard discriminant > 0 else { return nil }

        return niOverNt * (uv - n*dt) - n*sqrt(discriminant)
    }

}
