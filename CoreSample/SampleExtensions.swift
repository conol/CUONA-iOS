//
//  SampleExtensions.swift
//  CoreSample
//
//  Created by mizota takaaki on 2018/02/25.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

import UIKit


//MARK: - 拡張クラス
extension UITextField {
    
    // nil, 空文字, 空白ならtrueを返す
    var isBlank: Bool {
        return text?.replacingOccurrences(of: " ", with: "").isEmpty ?? true
    }
    
    // 指定文字数以上ならtrueを返す
    func isMoreThan(_ characterNum: Int) -> Bool {
        return characterNum <= (text?.count)!
    }
}

extension UIButton
{
    func makeRoundButton(_ textColor:String, backgroundColor:String)
    {
        clipsToBounds      = true
        layer.cornerRadius = 4.0
        setTitleColor(UIColor.hexStr(textColor, alpha: 1.0), for: .normal)
        setTitleColor(UIColor.hexStr(textColor, alpha: 0.2), for: .disabled)
        setBackgroundImage(UIImage.createColor(backgroundColor, alpha: 0.2), for: .disabled)
        setBackgroundImage(UIImage.createColor(backgroundColor, alpha: 1.0), for: .normal)
    }
}

extension UIColor
{
    static func hexStr(_ hexStr:String, alpha:CGFloat) -> UIColor
    {
        let hex = hexStr.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            return UIColor.white
        }
    }
}

extension UIImage
{
    static func createColor(_ color:String, alpha:CGFloat) -> UIImage
    {
        let rect = CGRect(x:0, y:0, width:1, height:1)
        UIGraphicsBeginImageContext(rect.size)
        let contextRef = UIGraphicsGetCurrentContext()
        contextRef!.setFillColor(UIColor.hexStr(color, alpha: alpha).cgColor)
        contextRef!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
    class func resizeImage (_ image:UIImage, quality:CGInterpolationQuality, size:CGSize) -> UIImage
    {
        let width:CGFloat  = size.width;
        let height:CGFloat = size.height;
        
        let widthRatio:CGFloat  = width / image.size.width;
        let heightRatio:CGFloat = height / image.size.height;
        let ratio:CGFloat = (widthRatio > heightRatio) ? widthRatio : heightRatio;
        
        let rect = CGRect(x:0, y:0, width:image.size.width*ratio, height:image.size.height*ratio)
        
        UIGraphicsBeginImageContext(rect.size);
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        context.interpolationQuality = quality;
        image.draw(in: rect)
        let resized:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        
        return resized;
    }
    
    class func saveImage (_ imageData:NSData, path:String, filename:String) -> Bool
    {
        let filepath = "\(path)/\(filename).png"
        
        if imageData.write(toFile: filepath, atomically: true) {
            return true
        } else {
            return false
        }
    }
    
    class func loadImage (_ path:String, filename:String) -> UIImage?
    {
        return UIImage(contentsOfFile: "\(path)/\(filename).png")
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined(separator: " ")
    }
}
