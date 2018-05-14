//
//  Extensions.swift
//  MONIQUA-iOS
//
//  Created by 溝田隆明 on 2017/07/26.
//  Copyright © 2017年 conol, Inc. All rights reserved.
//

import UIKit
import Foundation

let center = NotificationCenter.default
let ud = UserDefaults.standard

//MARK: - アラート画面をどこからでも出す機能
public class Alert
{
    public static var alert:UIAlertController!
    
    public static func show(title:String, message:String)
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
    @available(iOS 11.0, *)
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

extension Date
{
    @available(iOS 11.0, *)
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String
{
    @available(iOS 11.0, *)
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
    
    var toDictionary: [String: Any]? {
        let data = self.data(using: .utf8)!
        var jsonDic: [String: Any]? = nil
        do {
            jsonDic = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            return nil
        }
        return jsonDic
    }
    
    public func split(_ length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        let array = self.map { "\($0)" }
        let limit = array.count
        
        let results = stride(from: 0, to: limit, by: length).map {
            array[$0..<min($0.advanced(by: length), limit)].joined(separator: "")
        }
        return results.joined(separator: " ")
    }
    
    func encodeUrl() -> String?
    {
        return self.addingPercentEncoding( withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
    
    func decodeUrl() -> String?
    {
        return self.removingPercentEncoding
    }
}
