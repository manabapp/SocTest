//
//  String+Extension.swift
//  LibSoc - Swifty POSIX Socket Library
//
//  Created by Hirose Manabu on 2021/01/31.
//

import Foundation

extension String {
    var length: Int {
        let string_NS = self as NSString
        return string_NS.length
    }
    
    func pregMatche(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.length))
        return matches.count > 0
    }
    
    var isValidIPv4Format: Bool {
        self.pregMatche(pattern: "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$")
    }
    
    var isValidPath: Bool {
        self.pregMatche(pattern: "^[a-zA-Z0-9][.a-zA-Z0-9_-]*$")
    }

    var isValidName: Bool {
        self.pregMatche(pattern: "^[a-zA-Z0-9][.a-zA-Z0-9_-]*$")
    }
}
