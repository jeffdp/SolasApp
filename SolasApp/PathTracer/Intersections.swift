//  Copyright © 2022 Jeff Porter. All rights reserved.

import simd

struct Hit {
    let t: Float
    let p: vec3
    let normal: vec3
    let material: Material
}

protocol Hitable {
    func hit(ray: Ray, min: Float, max: Float) -> Hit?
}

func hit(ray: Ray,
         min: Float = 0.001,
         max: Float = Float.greatestFiniteMagnitude,
         objects: [Hitable]) -> Hit? {
    var closestHit: Hit?

    for object in objects {
        if let newHit = object.hit(ray: ray, min: min, max: max) {
            if newHit.t < (closestHit?.t ?? Float.greatestFiniteMagnitude) {
                closestHit = newHit
            }
        }
    }

    return closestHit
}

struct Sphere: Hitable {
    let center: vec3
    let radius: Float
    let material: Material

    func hit(ray: Ray, min: Float, max: Float) -> Hit? {
        let oc = ray.origin - center
        let a = dot(ray.direction, ray.direction)
        let b = dot(oc, ray.direction)
        let c = dot(oc, oc) - radius*radius
        let discriminant = b*b - a*c

        // check that we hit a sphere in front of the ray
        guard discriminant >= 0 else { return nil }

        var temp = (-b - sqrt(discriminant))/a
        if temp < max && temp > min {
            let point = ray.point(at: temp)
            return Hit(t: temp, p: point, normal: (point - center) / radius, material: material)
        }

        temp = (-b + sqrt(discriminant))/a
        if temp < max && temp > min {
            let point = ray.point(at: temp)
            return Hit(t: temp, p: point, normal: (point - center) / radius, material: material)
        }

        return nil
    }
}
