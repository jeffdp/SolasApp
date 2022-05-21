//  Copyright © 2022 Jeff Porter. All rights reserved.

import Foundation

struct Color {
    var alpha: UInt16 = 255
    var red: UInt16
    var green: UInt16
    var blue: UInt16
    
    var line: String {
        "\(red) \(green) \(blue)\n"
    }

    init() {
        self.red = 0
        self.green = 0
        self.blue = 0
    }

    init(_ red: UInt16, _ green: UInt16, _ blue: UInt16) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    init(x: Double, y: Double, z: Double) {
        self.init(UInt16(x*255.9), UInt16(y*255.9), UInt16(z*255.9))
    }
    
    init(_ vec: SIMD3<Float>) {
        self.init(x: Double(vec.x), y: Double(vec.y), z: Double(vec.z))
    }
    
    init(_ pixel: Pixel) {
        self.alpha = UInt16(pixel.alpha)
        self.red = UInt16(pixel.red)
        self.green = UInt16(pixel.green)
        self.blue = UInt16(pixel.blue)
    }

    func gamma2() -> Color {
        let red = sqrt(Double(red)/255.0)
        let green = sqrt(Double(green)/255.0)
        let blue = sqrt(Double(blue)/255.0)

        return Color(x: red, y: green, z: blue)
    }

    static func + (_ lhs: Color, _ rhs: Color) -> Color {
        Color(lhs.red + rhs.red, lhs.green + rhs.green, lhs.blue + rhs.blue)
    }

    static func / (_ lhs: Color, _ rhs: Double) -> Color {
        Color(lhs.red/UInt16(rhs), lhs.green/UInt16(rhs), lhs.blue/UInt16(rhs))
    }

    static func * (_ lhs: Color, _ rhs: Color) -> Color {
        Color(lhs.red*rhs.red, lhs.green*rhs.green, lhs.blue*rhs.blue)
    }

    static func * (_ lhs: vec3, _ rhs: Color) -> Color {
        let r = UInt16(lhs.x * Float(rhs.red))
        let g = UInt16(lhs.y * Float(rhs.green))
        let b = UInt16(lhs.z * Float(rhs.blue))

        return Color(r, g, b)
    }
}
