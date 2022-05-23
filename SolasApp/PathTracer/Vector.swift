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
    
    static func *(lhs: Float, rhs: vec3) -> vec3 {
        vec3(lhs * rhs.x, lhs * rhs.y, lhs * rhs.z)
    }
    
    static func +(lhs: Float, rhs: vec3) -> vec3 {
        vec3(lhs + rhs.x, lhs + rhs.y, lhs + rhs.z)
    }
    
    static func +(lhs: vec3, rhs: vec3) -> vec3 {
        vec3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
}
