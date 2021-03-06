//
//  Extension.swift
//  ScrapFaceDemo
//
//  Created by Fumitoshi Ogata on 2014/12/16.
//  Copyright (c) 2014年 Fumitoshi Ogata. All rights reserved.
//

import UIKit

extension UIColor {
    
    func getRGB() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (red: (r * 255.0), green: (g * 255.0), blue: (b * 255.0), alpha: a)
    }
    
    
}
extension UIImage {
    
    
    
    func getMaskImageFromTappedColor(_tColor:UIColor) -> UIImage? {
        
        var _image = self
        var _imageSize = _image.size
        var _width = Int(_imageSize.width)
        var _height = Int(_imageSize.height)
        var _imageData = _image.imageData()
        
        var imageBytes : UnsafeMutablePointer<Byte>;
        let newByteLength = _width * _height * 4
        imageBytes = UnsafeMutablePointer<Byte>.alloc(newByteLength)
        
        var _cnt = 0;
        
        for x in 0..<_width {
            for y in 0..<_height {
                var point = (x, y)
                var color = UIImage.colorAtPoint(
                    point,
                    imageWidth: _width,
                    withData: _imageData
                )
                let i = (x + y * _width) * 4;
                
                imageBytes[i] = Byte(color.getRGB().red) // red
                imageBytes[i+1] = Byte(color.getRGB().green); // green
                imageBytes[i+2] = Byte(color.getRGB().blue); // blue
                imageBytes[i+3] = Byte(255); // alpha
                
                /*
                //let (r, g, b) = renderAt((x, y))
                //if(color == UIColor.redColor()){
                if(color == _tColor){
                imageBytes[i] = Byte(255) // red
                imageBytes[i+1] = Byte(255); // green
                imageBytes[i+2] = Byte(255); // blue
                imageBytes[i+3] = Byte(255); // alpha
                }else{
                /*
                imageBytes[i] = Byte(0) // red
                imageBytes[i+1] = Byte(0); // green
                imageBytes[i+2] = Byte(0); // blue
                imageBytes[i+3] = Byte(255); // alpha
                */
                imageBytes[i] = Byte(_tColor.getRGB().red) // red
                imageBytes[i+1] = Byte(_tColor.getRGB().green); // green
                imageBytes[i+2] = Byte(_tColor.getRGB().blue); // blue
                imageBytes[i+3] = Byte(255); // alpha
                }*/
                _cnt++
            }
        } 
        var provider = CGDataProviderCreateWithData(nil,imageBytes, UInt(newByteLength), nil)
        var bitsPerComponent:UInt = 8
        var bitsPerPixel:UInt = 32
        var bytesPerRow:UInt = UInt(4) * UInt(_width)
        var colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo = CGBitmapInfo.ByteOrderDefault
        var renderingIntent = kCGRenderingIntentDefault
        // make the cgimage
        var cgImage = CGImageCreate(UInt(_width), UInt(_height), bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, nil, false, renderingIntent)
        return UIImage(CGImage: cgImage)
    }
    
    
    func imageFromSceneKitViewOriginal(bytes: UnsafeMutablePointer<Byte>) -> UIImage? {
        
        var imageBytes : UnsafeMutablePointer<Byte>;
        imageBytes = nil;
        
        
        //var w:UInt = UInt(sceneKitView.bounds.size.width * UIScreen.mainScreen().scale)
        //var h:UInt = UInt(sceneKitView.bounds.size.height * UIScreen.mainScreen().scale)
        var w:UInt = 10
        var h:UInt = 10
        
        let myDataLength:UInt = w * h * UInt(4)
        //var bytes = UnsafeMutablePointer<CGFloat>(calloc(myDataLength, UInt(sizeof(CUnsignedChar))))
        //glReadPixels(0, 0, GLint(w), GLint(h), GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), bytes)
        
        var provider = CGDataProviderCreateWithData(nil, bytes, UInt(myDataLength), nil)
        var bitsPerComponent:UInt = 8
        var bitsPerPixel:UInt = 32
        var bytesPerRow:UInt = UInt(4) * UInt(w)
        var colorSpaceRef = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo = CGBitmapInfo.ByteOrderDefault
        var renderingIntent = kCGRenderingIntentDefault
        
        // make the cgimage
        var cgImage = CGImageCreate(UInt(w), UInt(h), bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, nil, false, renderingIntent)
        return UIImage(CGImage: cgImage)
    }
    
    class func colorAtPoint(point: (x: Int, y: Int), imageWidth: Int, withData data: UnsafePointer<UInt8>) -> UIColor {
        let offset = 4 * ((imageWidth * point.y) + point.x)
        
        var r = CGFloat(data[offset])
        var g = CGFloat(data[offset + 1])
        var b = CGFloat(data[offset + 2])
        
        //return (red: r, green: g, blue: b)
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    func scaleToSize(toSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(toSize,false, 0.0)
        drawInRect(CGRectMake(0, 0, toSize.width, toSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func imageData() -> UnsafePointer<UInt8> {
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        return CFDataGetBytePtr(pixelData)
    }    
    
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        var data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        var r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        var g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        var b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        var a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    
    func fitnessBetweenImages(_tColor:UIColor) -> Void {
        var _image = self
        var _imageSize = _image.size
        var _width = Int(_imageSize.width)
        var _height = Int(_imageSize.height)
        var _imageData = _image.imageData()
        var _cnt = 0
        for x in 0..<_width {
            for y in 0..<_height {
                var point = (x, y)
                var color = UIImage.colorAtPoint(
                    point,
                    imageWidth: _width,
                    withData: _imageData
                )
                if(color == _tColor){
                    println("atari!")
                }
                _cnt++
            }
        }
        //println(_cnt)
    }
    
    
    func getColor() -> String{
        /*
        var pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        var buffer: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let imageSize = self.size
        for x in 0..<Int(imageSize.width) {
        for y in 0..<Int(imageSize.height) {
        
        //ピクセルのポインタを取得する
        let point = (x, y)
        
        let offset = 4 * ((Int(imageSize.width) * y) + x)
        
        var r = CGFloat(data[offset])
        var g = CGFloat(data[offset + 1])
        var b = CGFloat(data[offset + 2])
        
        //let colorA = UIImage.colorAtPoint(point, imageWidth: width, withData: imageAData)
        //let colorB = UIImage.colorAtPoint(point, imageWidth: width, withData: imageBData)
        
        //fitness += distanceBetweenColors(colorA, colorB) as Fitness
        }
        }
        
        
        
        
        
        //var span : style = "color: rgb(0, 128, 128)"
        //for (x=0; x<self.size.width; x++) {
        for x in 0...Int(self.size.width){
        //for (y=0; y<self.size.height; y++) {
        for y in 0...Int(self.size.height){
        // ピクセルのポインタを取得する
        var pixelPtr : UInt8 = buffer + Int(y) * bytesPerRow + Int(x) * 4;
        
        // 色情報を取得する
        //var r : UInt8 = *(pixelPtr + 2);  // 赤
        //var g : UInt8 = *(pixelPtr + 1);  // 緑
        //var b : UInt8 = *(pixelPtr + 0);  // 青
        
        //NSLog(@"x:%d y:%d R:%d G:%d B:%d", x, y, r, g, b);
        }
        }
        
        */
        
        /*
        UIImage *image = [UIImage imageNamed:@"sample.png"];
        
        // CGImageを取得する
        CGImageRef  imageRef = image.CGImage;
        // データプロバイダを取得する
        CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
        
        // ビットマップデータを取得する
        CFDataRef dataRef = CGDataProviderCopyData(dataProvider);
        UInt8* buffer = (UInt8*)CFDataGetBytePtr(dataRef);
        
        size_t bytesPerRow                = CGImageGetBytesPerRow(imageRef);
        
        span style="color: rgb(0, 128, 128);"> // 画像全体を１ピクセルずつ走査する
        for (int x=0; x<image.size.width; x++) {
        for (int y=0; y<image.size.height; y++) {
        // ピクセルのポインタを取得する
        UInt8*  pixelPtr = buffer + (int)(y) * bytesPerRow + (int)(x) * 4;
        
        // 色情報を取得する
        UInt8 r = *(pixelPtr + 2);  // 赤
        UInt8 g = *(pixelPtr + 1);  // 緑
        UInt8 b = *(pixelPtr + 0);  // 青
        
        NSLog(@"x:%d y:%d R:%d G:%d B:%d", x, y, r, g, b);
        }
        }
        
        CFRelease(dataRef);
        */
        
        
        return "aaa"
    }
    
}
