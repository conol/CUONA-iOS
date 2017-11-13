//
//  Extensions.swift
//  MONIQUA-iOS
//
//  Created by 溝田隆明 on 2017/07/26.
//  Copyright © 2017年 conol, Inc. All rights reserved.
//

import UIKit
import Foundation

//MARK: - アラート画面をどこからでも出す機能
class Alert
{
    internal static var alert:UIAlertController!
    
    internal static func show(title:String, message:String)
    {
        alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let controller = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            controller.present(alert, animated: true, completion: nil)
        } else {
            UIApplication.shared.delegate?.window!!.rootViewController?.present(alert, animated: true, completion: nil)
        }
        return
    }
}

extension Formatter
{
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        return formatter
    }()
}

extension Date
{
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String
{
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
}
