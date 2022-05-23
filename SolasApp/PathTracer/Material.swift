//  Copyright © 2022 Jeff Porter. All rights reserved.

import simd

protocol Material {
    func scatter(ray: Ray, hit: Hit) -> (attenuation: vec3, scattered: Ray)?
}

class LambertianMaterial: Material {
    let albedo: vec3

    init(_ albedo: vec3) {
        self.albedo = albedo
    }

    func scatter(ray: Ray, hit: Hit) -> (attenuation: vec3, scattered: Ray)? {
        let target = hit.p + hit.normal + Ray.randomInUnitSphere()
        let scattered = Ray(hit.p, target - hit.p)
        let attenuation = albedo

        return (attenuation, scattered)
    }
}

class MetalMaterial: Material {
    let albedo: vec3
    let fuzz: Float

    init(_ albedo: vec3, fuzz: Float) {
        self.albedo = albedo

        self.fuzz = Float.minimum(fuzz, 1)
    }

    func scatter(ray: Ray, hit: Hit) -> (attenuation: vec3, scattered: Ray)? {
        let reflected = ray.direction.normalized().reflect(hit.normal)
        let scattered = Ray(hit.p, reflected + fuzz * Ray.randomInUnitSphere())
        let attenuation = albedo

        guard dot(scattered.direction, hit.normal) > 0 else { return nil }

        return (attenuation, scattered)
    }
}

class DialectricMaterial: Material {
    let refractiveIndex: Float

    init(refractiveIndex: Float) {
        self.refractiveIndex = refractiveIndex
    }

    private func schlick(cosine: Float, refractionIndex: Float) -> Float {
        let r0 = (1 - refractiveIndex) / (1 + refractiveIndex)
        let r02 = r0 * r0

        return r02 + (1 - r02) * pow(1 - cosine, 5)
    }

    func scatter(ray: Ray, hit: Hit) -> (attenuation: vec3, scattered: Ray)? {
        let reflected = ray.direction.reflect(hit.normal)
        let attenuation = vec3(1, 1, 1)
        
        let outwardNormal: vec3
        let niOverNt: Float
        let cosine: Float

        if dot(ray.direction, hit.normal) > 0 {
            outwardNormal = -hit.normal
            niOverNt = refractiveIndex
            cosine = refractiveIndex * dot(ray.direction, hit.normal) / ray.direction.length
        } else {
            outwardNormal = hit.normal
            niOverNt = 1.0 / refractiveIndex
            cosine = -dot(ray.direction, hit.normal) / ray.direction.length
        }

        if let refracted = ray.direction.refract(outwardNormal, niOverNt: niOverNt) {
            let reflectProbability = schlick(cosine: cosine, refractionIndex: refractiveIndex)
            if Float.random(in: 0...1) < reflectProbability {
                return (attenuation: attenuation, scattered: Ray(hit.p, reflected))
            } else {
                return (attenuation: attenuation, scattered: Ray(hit.p, refracted))
            }
        } else {
            return (attenuation: attenuation, scattered: Ray(hit.p, reflected))
        }
    }
}
