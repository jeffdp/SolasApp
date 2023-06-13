//
//  Image.swift
//  SolasApp
//
//  Created by Jeffrey Porter on 5/21/22.
//

import SwiftUI

#if os(macOS)
import AppKit

func imageFromBitmap(width: Int, height: Int, pixels: [Color]) -> NSImage? {
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

    let bitsPerComponent = 8
    let bitsPerPixel = 32
    let pixelSize = MemoryLayout.size(ofValue: Color())
    let bytesPerRow = pixelSize * width
    var data = pixels

    guard let provider = CGDataProvider(data: NSData(bytes: &data, length: data.count * pixelSize)) else {
        return nil
    }

    guard let cgImage = CGImage(width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bitsPerPixel: bitsPerPixel,
                                bytesPerRow: bytesPerRow,
                                space: rgbColorSpace,
                                bitmapInfo: bitmapInfo,
                                provider: provider,
                                decode: nil,
                                shouldInterpolate: true,
                                intent: .defaultIntent) else {
        return nil
    }

    return NSImage(cgImage: cgImage, size: CGSize(width: width, height: height))
}
#elseif os(iOS)
import UIKit

func imageFromBitmap(width: Int, height: Int, pixels: [Color]) -> UIImage? {
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

    let bitsPerComponent = 8
    let bitsPerPixel = 32
    let pixelSize = MemoryLayout.size(ofValue: Color())
    let bytesPerRow = pixelSize * width
    var data = pixels

    guard let provider = CGDataProvider(data: NSData(bytes: &data, length: data.count * pixelSize)) else {
        return nil
    }

    guard let cgImage = CGImage(width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bitsPerPixel: bitsPerPixel,
                                bytesPerRow: bytesPerRow,
                                space: rgbColorSpace,
                                bitmapInfo: bitmapInfo,
                                provider: provider,
                                decode: nil,
                                shouldInterpolate: true,
                                intent: .defaultIntent) else {
        return nil
    }

//    return UIImage(cgImage: cgImage, size: CGSize(width: width, height: height))

    return UIImage(cgImage: cgImage)
}
#endif



//func test(width: Int, height: Int, pixels: [Color]) {
//    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
//
//    let pixelData = UInt8[width * height * 3]()
//    for (size_t ui = 0; ui < width * height * 3; ui++) {
//      pixelData[ui] = 210
//    }
//
//    let colorspace = CGColorSpaceCreateDeviceRGB()
//    let rgbData = CFDataCreate(NULL, pixelData, 64 * 64 * 3)
//    let provider = CGDataProviderCreateWithCFData(rgbData)
//    let rgbImageRef = CGImageCreate(width, height, 24, 8, width * 3, CGColorSpaceCreateDeviceRGB(), <#T##bitmapInfo: CGBitmapInfo##CGBitmapInfo#>, <#T##provider: CGDataProvider##CGDataProvider#>, <#T##decode: UnsafePointer<CGFloat>?##UnsafePointer<CGFloat>?#>, <#T##shouldInterpolate: Bool##Bool#>, <#T##intent: CGColorRenderingIntent##CGColorRenderingIntent#>)
//    
//    
//    let rgbImageRef = CGImageCreate(width, 64, 8, 24, 64 * 3, colorspace, kCGBitmapByteOrderDefault, provider, NULL, true, kCGRenderingIntentDefault);
//
//    CFRelease(rgbData);
//
//    CGDataProviderRelease(provider);
//
//    CGColorSpaceRelease(colorspace);
//
//    // use the created CGImage
//
//    CGImageRelease(rgbImageRef);
//
//}
