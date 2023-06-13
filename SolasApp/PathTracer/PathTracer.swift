//  Copyright © 2022 Jeff Porter. All rights reserved.

import SwiftImage
import SwiftUI

#if os(macOS)
import AppKit
typealias OSImage = NSImage
#elseif os(iOS)
import UIKit
typealias OSImage = UIImage
#endif

class PathTracer {
    static let progressNotification = Notification.Name("RenderProgressNotification")
    
    // MARK: - Async API

    func renderGraident(row: Int, width: Int, height: Int) -> [RGBA<UInt8>] {
        let camera = Camera(lowerLeft: vec3(-2, -1, -1),
                            horizontal: vec3(4, 0, 0),
                            vertical: vec3(0, 2, 0),
                            origin: vec3(0, 0, 0))

        var pixels = [RGBA<UInt8>]()
        pixels.reserveCapacity(width)

        for i in 0..<width {
            let u = (Float(i) + 0.5) / Float(width)
            let v = (Float(row) + 0.5) / Float(height)
            let ray = camera.ray(u: u, v: v)
            let color = gradient(ray: ray)

            let pixel = RGBA(red: UInt8(color.red),
                             green: UInt8(color.green),
                             blue: UInt8(color.blue))
            pixels.append(pixel)
        }

        return pixels
    }

    func renderGradient(range: Range<Int>, width: Int, height: Int) -> [RGBA<UInt8>]  {
        var pixels = [RGBA<UInt8>]()
        pixels.reserveCapacity(width * range.count)

        let camera = Camera(lowerLeft: vec3(-2, -1, -1),
                            horizontal: vec3(4, 0, 0),
                            vertical: vec3(0, 2, 0),
                            origin: vec3(0, 0, 0))

        for j in range.reversed() {
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

        return pixels
    }

    func renderGradient(width: Int, height: Int) async throws -> OSImage {
        return await withCheckedContinuation { continuation in
            let image = gradient(width: width, height: height)

            continuation.resume(returning: image)
        }
    }

    func renderTaskGradient(width: Int, height: Int) async throws -> OSImage {
        var pixels = [Int:[RGBA<UInt8>]]()

        try await withThrowingTaskGroup(of: (Int, [RGBA<UInt8>]).self) { group in
            let steps = 10
            pixels.reserveCapacity(steps)

            let stepSize = Int(height / steps)
            let remaining = height - steps * stepSize

            var ranges = [Range<Int>]()
            
            for i in 0..<steps {
                let start = i * stepSize
                let range = start..<(start + stepSize)
                ranges.append(range)
            }

            if remaining > 0 {
                ranges.append((height - remaining)..<height)
            }

            for rangeIndex in (0..<ranges.count).reversed() {
                let range = ranges[rangeIndex]

                group.addTask {
                    return (rangeIndex, self.renderGradient(range: range, width: width, height: height))
                }
            }

            for try await (index, value) in group {
                pixels[index] = value
            }
        }

        var fullImage = [RGBA<UInt8>]()
        fullImage.reserveCapacity(width * height)

        for subImage in pixels.sorted(by: { $0.key > $1.key}).map({ $0.value }) {
            fullImage.append(contentsOf: subImage)
        }

        #if os(macOS)
        return Image(width: width, height: height, pixels: fullImage).nsImage
        #elseif os(iOS)
        return Image(width: width, height: height, pixels: fullImage).uiImage
        #endif
    }
    
    func renderSingle(scene: RenderScene, width: Int, height: Int, numberOfSamples: Int) async throws -> OSImage {
        return await withCheckedContinuation { continuation in
            let image = trace(scene: scene,
                              width: width,
                              height: height,
                              numberOfSamples: numberOfSamples)
            
            continuation.resume(returning: image)
        }
    }
    
    func renderSimpleAsync(scene: RenderScene, width: Int, height: Int, numberOfSamples: Int) async throws -> OSImage {
        return try await renderGradient(width: width, height: height)
    }
    
    func renderTaskGroup(scene: RenderScene, width: Int, height: Int, numberOfSamples: Int) async throws -> OSImage {
        return try await renderTaskGradient(width: width, height: height)
    }
    
    // MARK: - Internal methods
    
    private func trace(scene: RenderScene, width: Int, height: Int, numberOfSamples: Int) -> OSImage {
        let sceneInfo = RenderScenes().scene(for: scene)
        
        var pixels = [RGBA<UInt8>]()
        pixels.reserveCapacity(width * height)

        for j in (0..<height).reversed() {
            for i in 0..<width {
                if i % 100 == 0 {
                    let progress = Double(height - 1 - j)/Double(height) + (Double(i) / (Double(width * height)))
                    NotificationCenter.default.post(name: Self.progressNotification, object: progress)
                }
                
                var accumulatedColor = Color()
                for _ in 0..<numberOfSamples {
                    let u = (Float(i) + Float.random(in: 0...1)) / Float(width)
                    let v = (Float(j) + Float.random(in: 0...1)) / Float(height)
                    let ray = sceneInfo.camera.ray(u: u, v: v)
                    let sample = color(ray, objects: sceneInfo.objects, depth: 0)

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

        #if os(macOS)
        return image.nsImage
        #elseif os(iOS)
        return image.uiImage
        #endif
    }
    
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

    private func gradient(width: Int, height: Int) -> OSImage {
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
        
        #if os(macOS)
        return image.nsImage
        #elseif os(iOS)
        return image.uiImage
        #endif
    }
}
