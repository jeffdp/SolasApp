//  Copyright © 2022 Jeff Porter. All rights reserved.

import Foundation

class RenderScenes {
    func scene(for type: RenderScene) -> Renderable {
        switch type {
        case .twoSpheres: return TwoSpheres()
        case .fourSpheres: return FourSpheres()
        case .randomSpheres: return RandomSpheres()
        }
    }
}

enum RenderScene: Hashable, Identifiable {
    var id: Self { self }
    
    case twoSpheres
    case fourSpheres
    case randomSpheres
}

protocol Renderable {
    var camera: Camera { get }
    var objects: [Hitable] { get }
}

struct TwoSpheres: Renderable {
    let camera: Camera
    let objects: [Hitable]
    
    init() {
        let lookfrom = vec3(13,2,3)
        let lookat = vec3(0,0,0)
        let vup = vec3(0,1,0)
        let distToFocus: Float = 10.0
        let aspectRatio: Float = 16.0 / 9.0;
        
        self.camera = Camera(lookFrom: lookfrom,
                             lookAt: lookat,
                             vertical: vup,
                             vfov: 20,
                             aspect: aspectRatio,
                             aperture: aspectRatio,
                             focusDist: distToFocus)
        
        self.objects = [
            Sphere(center: vec3(0, 0, -1), radius: 0.5, material: LambertianMaterial(vec3(0.1, 0.1, 0.8))),
            Sphere(center: vec3(0, -100.5, 0.5), radius: 100, material: LambertianMaterial(vec3(0.8, 0.8, 0.0)))
        ]
    }
}

struct FourSpheres: Renderable {
    let camera: Camera
    let objects: [Hitable]
    
    init() {
        self.camera = Camera(lowerLeft: vec3(-2, -1, -1),
                             horizontal: vec3(4, 0, 0),
                             vertical: vec3(0, 2, 0),
                             origin: vec3(0, 0, 0))
        self.objects = [
            Sphere(center: vec3(0, 0, -1),
                   radius: 0.5,
                   material: LambertianMaterial(vec3(0.8, 0.3, 0.3))),
            Sphere(center: vec3(0, -100.5, -1),
                   radius: 100,
                   material: LambertianMaterial(vec3(0.8, 0.8, 0.0))),
            Sphere(center: vec3(1, 0, -1),
                   radius: 0.5,
                   material: MetalMaterial(vec3(0.8, 0.6, 0.2), fuzz: 0.5)),
            Sphere(center: vec3(-1, 0, -1),
                   radius: 0.5,
                   material: DialectricMaterial(refractiveIndex: 1.5)),
        ]
    }
}

struct RandomSpheres: Renderable {
    let camera: Camera
    let objects: [Hitable]
    
    init() {
        let lookfrom = vec3(13,2,3)
        let lookat = vec3(0,0,0)
        let vup = vec3(0,1,0)
        let distToFocus: Float = 10.0
        let aspectRatio: Float = 16.0 / 9.0;
        
        self.camera = Camera(lookFrom: lookfrom,
                             lookAt: lookat,
                             vertical: vup,
                             vfov: 20,
                             aspect: aspectRatio,
                             aperture: aspectRatio,
                             focusDist: distToFocus)
        
        var spheres = [Sphere]()
        
        spheres.append(Sphere(center: vec3(0, -1000, 0),
                              radius: 1000,
                              material: LambertianMaterial(vec3(0.5, 0.5, 0.5))))
        
        for a in -11...11 {
            for b in -11...11 {
                let center = vec3(Float(a) + Float(0.9) * Float.random(in: 0...1),
                                  0.2,
                                  Float(b) + Float(0.9) * Float.random(in: 0...1))
                if (center - vec3(4.0, 0.2, 0.0)).length > Float(0.9) {
                    let material = Float.random(in: 0...1)
                    if material < 0.8 {
                        let albedo = vec3(Float.random(in: 0...1) * Float.random(in: 0...1),
                                          Float.random(in: 0...1) * Float.random(in: 0...1),
                                          Float.random(in: 0...1) * Float.random(in: 0...1))
                        spheres.append(Sphere(center: center, radius: 0.2, material: LambertianMaterial(albedo)))
                    } else if material < 0.95 {
                        let metal = vec3(0.5*(1+Float.random(in: 0...1)),
                                         0.5*(1+Float.random(in: 0...1)),
                                         0.5*(1+Float.random(in: 0...1)))
                        let fuzz = 0.5 * Float.random(in: 0...1)
                        spheres.append(Sphere(center: center, radius: 0.2,
                                              material: MetalMaterial(metal, fuzz: fuzz)))
                    } else {
                        spheres.append(Sphere(center: center, radius: 0.2,
                                              material: DialectricMaterial(refractiveIndex: 1.5)))
                    }
                } else {
                    spheres.append(Sphere(center: center, radius: 0.2, material: DialectricMaterial(refractiveIndex: 1.5)))
                }
            }
        }
        
        spheres.append(Sphere(center: vec3(0, 1, 0), radius: 1.0, material: DialectricMaterial(refractiveIndex: 1.5)))
        spheres.append(Sphere(center: vec3(-4, 1, 0), radius: 1.0, material: LambertianMaterial(vec3(0.4, 0.2, 0.1))))
        spheres.append(Sphere(center: vec3(4, 1, 0), radius: 1.0, material: MetalMaterial(vec3(0.7, 0.6, 0.5), fuzz: 0.0)))
        
        self.objects = spheres
    }
}
