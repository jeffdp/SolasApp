//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftImage
import AppKit

actor PathTracer {
    // MARK: - Async API
    
    func renderGradient(width: Int, height: Int) async throws -> NSImage {
        return await withCheckedContinuation { continuation in
            print("gradient: isMain=\(Thread.isMainThread)")
            
            let image = gradient(width: width, height: height)
            
            continuation.resume(returning: image)
        }
    }
    
    func renderSingle(width: Int, height: Int, numberOfSamples: Int) async throws -> NSImage {
        return await withCheckedContinuation { continuation in
            print("  single: isMain=\(Thread.isMainThread)")
            
            let image = trace(width: width, height: height, numberOfSamples: numberOfSamples)
            
            continuation.resume(returning: image)
        }
    }
    
    func renderSimpleAsync(width: Int, height: Int) async throws -> NSImage {
        print("  simple: isMain=\(Thread.isMainThread)")
        return try await renderGradient(width: width, height: height)
    }
    
    func renderTaskGroup(width: Int, height: Int) async throws -> NSImage {
        print("    task: isMain=\(Thread.isMainThread)")
        return try await renderGradient(width: width, height: height)
    }
    
    // MARK: - Internal methods
    
    private func gradient(ray: Ray) -> Color {
        let direction = ray.direction.normalized()
        let t = Float((direction.y + 1.0) / 2.0)
        let gradient = (1.0 - t) * SIMD3<Float>([1, 1, 1]) + t * SIMD3<Float>([0.5, 0.7, 1.0])
        return Color(gradient)
    }
    
    private func color(_ ray: Ray, objects: [Hitable], depth: Int) -> Color {
        if let hit = hit(ray: ray, objects: objects) {
            guard depth < 10,
                let (attenuation, scattered) = hit.material.scatter(ray: ray, hit: hit) else {
                return Color()
            }

            return attenuation * color(scattered, objects: objects, depth: depth+1)
        }

        let unitDirection = ray.direction.normalized()
        let t = 0.5 * unitDirection.y + 1.0
        let lerp = (1.0 - t) * vec3(1.0, 1.0, 1.0) + t*vec3(0.5, 0.7, 1.0)

        return Color(lerp)
    }

    private func gradient(width: Int, height: Int) -> NSImage {
        var pixels = [RGBA<UInt8>]()
        pixels.reserveCapacity(width * height)

        let camera = Camera(lowerLeft: vec3(-2, -1, -1),
                            horizontal: vec3(4, 0, 0),
                            vertical: vec3(0, 2, 0),
                            origin: vec3(0, 0, 0))

        for j in (0..<height).reversed() {
            for i in 0..<width {
                let u = (Float(i) + 0.5) / Float(width)
                let v = (Float(j) + 0.5) / Float(height)
                let ray = camera.ray(u: u, v: v)
                let color = gradient(ray: ray)

                let pixel = RGBA(red: UInt8(color.red),
                                 green: UInt8(color.green),
                                 blue: UInt8(color.blue))
                pixels.append(pixel)
            }
        }
        
        let image = Image(width: width, height: height, pixels: pixels)
        
        return image.nsImage
    }
    
    private func trace(width: Int, height: Int, numberOfSamples: Int) -> NSImage {
        var pixels = [RGBA<UInt8>]()
        pixels.reserveCapacity(width * height)

        let camera = Camera(lowerLeft: vec3(-2, -1, -1),
                            horizontal: vec3(4, 0, 0),
                            vertical: vec3(0, 2, 0),
                            origin: vec3(0, 0, 0))

        let spheres: [Hitable] = [
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

        for j in (0..<height).reversed() {
            if j % 100 == 0 {
                print("\(Double(height - j)/Double(height) * 100)%")
            }
            
            for i in 0..<width {
                var accumulatedColor = Color()
                for _ in 0..<numberOfSamples {
                    let u = (Float(i) + Float.random(in: 0...1)) / Float(width)
                    let v = (Float(j) + Float.random(in: 0...1)) / Float(height)
                    let ray = camera.ray(u: u, v: v)
                    let sample = color(ray, objects: spheres, depth: 0)

                    accumulatedColor = accumulatedColor + sample
                }

                accumulatedColor = (accumulatedColor / Double(numberOfSamples)).gamma2()

                let pixel = RGBA(red: UInt8(accumulatedColor.red),
                                 green: UInt8(accumulatedColor.green),
                                 blue: UInt8(accumulatedColor.blue))
                pixels.append(pixel)
            }
        }
        
        let image = Image(width: width, height: height, pixels: pixels)
        
        return image.nsImage
    }
}
