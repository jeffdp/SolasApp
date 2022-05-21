//  Copyright © 2022 Jeff Porter. All rights reserved.

import Foundation

struct Pixel {
    var alpha: UInt16 = 255
    var red: UInt16
    var green: UInt16
    var blue: UInt16
    
    init() {
        self.red = 0
        self.green = 0
        self.blue = 0
    }
    
    init(_ red: UInt16, _ green: UInt16, _ blue: UInt16) {
        self.red = UInt16(red)
        self.green = UInt16(green)
        self.blue = UInt16(blue)
    }

    init(_ red: Double, _ green: Double, _ blue: Double) {
        self.init(UInt16(red*255.9), UInt16(green*255.9), UInt16(blue*255.9))
    }

    init(red: UInt16, green: UInt16, blue: UInt16) {
        self.red = UInt16(red)
        self.green = UInt16(green)
        self.blue = UInt16(blue)
    }
    
    init(x: Double, y: Double, z: Double) {
        self.init(UInt16(x*255.9), UInt16(y*255.9), UInt16(z*255.9))
    }
    
    init(_ vec: SIMD3<Double>) {
        self.init(x: vec.x, y: vec.y, z: vec.z)
    }
    
    static func + (_ lhs: Pixel, _ rhs: Color) -> Pixel {
        Pixel(lhs.red + UInt16(rhs.red), lhs.green + UInt16(rhs.green), lhs.blue + UInt16(rhs.blue))
    }
    
    static func / (_ lhs: Pixel, _ rhs: Int) -> Pixel {
        Pixel(lhs.red/UInt16(rhs), lhs.green/UInt16(rhs), lhs.blue/UInt16(rhs))
    }
}

extension Pixel {
    static func gradient(width: Int, height: Int) -> String {
        var image = ""
        for j in (0..<height).reversed() {
            for i in 0..<width {
                let color = Color(x: Double(i)/Double(width),
                                  y: Double(j)/Double(height),
                                  z: Double(0.2))

                image.append(color.line)
            }
        }

        return image
    }
}
