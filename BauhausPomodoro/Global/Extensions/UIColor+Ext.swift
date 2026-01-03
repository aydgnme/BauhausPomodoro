//
//  UIColor+Ext.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

extension UIColor {
    /// Initialize UIColor with hex strings like "#RGB", "#RGBA", "#RRGGBB", or "#RRGGBBAA"
    convenience init?(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        // Expand short forms like RGB and RGBA to RRGGBB and RRGGBBAA
        if hexString.count == 3 || hexString.count == 4 {
            let chars = Array(hexString)
            hexString = chars.map { String([$0, $0]) }.joined()
        }

        var rgba: UInt64 = 0
        guard Scanner(string: hexString).scanHexInt64(&rgba) else { return nil }

        switch hexString.count {
        case 6: // RRGGBB
            let r = CGFloat((rgba & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((rgba & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(rgba & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        case 8: // RRGGBBAA
            let r = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
            let g = CGFloat((rgba & 0x00FF0000) >> 16) / 255.0
            let b = CGFloat((rgba & 0x0000FF00) >> 8) / 255.0
            let a = CGFloat(rgba & 0x000000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: a)
        default:
            return nil
        }
    }
}
