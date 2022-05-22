//  Copyright © 2022 Jeff Porter. All rights reserved.

import Foundation

enum RenderScene: Hashable, Identifiable {
    var id: Self { self }

    case fourSquares
}

protocol Renderable {
    var camera: Camera { get }
    var objects: [Hitable] { get }
}

struct FourSpheres: Renderable {
    var camera: Camera {
        Camera(lowerLeft: vec3(-2, -1, -1),
               horizontal: vec3(4, 0, 0),
               vertical: vec3(0, 2, 0),
               origin: vec3(0, 0, 0))
    }
    
    var objects: [Hitable] {
        [
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

class RenderScenes {
    func scene(for type: RenderScene) -> Renderable {
        switch type {
        case .fourSquares:
            return FourSpheres()
        }
    }
}
