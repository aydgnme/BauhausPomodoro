//
//  DesignSystem.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

struct DesignSystem {
    struct Colors {
        static let red = UIColor(hex: "#D62828")
        static let blue = UIColor(hex: "#003049")
        static let yellow = UIColor(hex: "#FCBF49")
        static let background = UIColor(hex: "#EAE2B7")
        static let black = UIColor(hex: "#000000")
    }
    
    struct Typography {
        static func boldFont(size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .black)
        }
        static func mediumFont(size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .bold)
        }
    }
}


