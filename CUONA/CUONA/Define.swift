//
//  Define.swift
//  CUONA
//
//  Created by mizota takaaki on 2018/02/06.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public enum Logging:Int
{
    case on  = 1
    case off = 2
}

struct NFCJsonData: Codable
{
    struct wifiDict: Codable {
        let id: String
        var ssid: String?
        var pass: String?
        var kind: Int?
        var days: Int?
    }
    
    struct favorDict: Codable {
        let id: String
    }
    
    struct roundsDict: Codable {
        let id: String
    }
    
    var wifi: wifiDict
    let favor: favorDict
    let rounds: roundsDict
}

@objc public enum CUONAType:Int
{
    case unknown = 0
    case cuona   = 1
    case seal    = 2
    
    public func name() -> String
    {
        switch self {
        case .cuona: return "CUONA本体"
        case .seal: return "シール"
        case .unknown: return "認識できない形式"
        }
    }
}

@objc public enum Service:Int
{
    case favor      = 1
    case wifihelper = 2
    case rounds     = 3
    case members    = 4
    case developer  = 1000
    
    public func id() -> String {
        switch self {
        case .favor:      return "UXbfYJ6SXm8G"
        case .wifihelper: return "H7Pa7pQaVxxG"
        case .rounds:     return "yhNuCERUMM58"
        case .members:    return "ReoDexKWs9a7"
        case .developer:  return ""
        }
    }
    
    public func name() -> String {
        switch self {
        case .favor:      return "Favor"
        case .wifihelper: return "WiFi HELPER"
        case .rounds:     return "Rounds"
        case .members:    return "MEMBERS"
        case .developer:  return ""
        }
    }
}

