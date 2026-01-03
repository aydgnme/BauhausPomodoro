//
//  PomodoroState.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

enum PomodoroState {
    case focus
    case shortBreak
    case longBreak
    
    var duration: Int {
        switch self {
        case .focus: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        }
    }
    
    var themeColor: UIColor {
        switch self {
        case .focus: return DesignSystem.Colors.red ?? .systemRed
        case .shortBreak: return DesignSystem.Colors.yellow ?? .systemYellow
        case .longBreak: return DesignSystem.Colors.blue ?? .systemBlue
        }
    }
    
    var title: String {
        switch self {
        case .focus: return "FOCUS"
        case .shortBreak: return "SHORT"
        case .longBreak: return "LONG"
        }
    }
}
