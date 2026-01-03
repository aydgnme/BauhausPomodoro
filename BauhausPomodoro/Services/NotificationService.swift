//
//  NotificationService.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit
import AudioToolbox

final class NotificationService {
    static let shared = NotificationService()
    
    func playCompletionHaptics() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func playSound() {
        AudioServicesPlaySystemSound(1005)
    }
}
