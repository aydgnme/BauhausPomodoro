//
//  PomodoroViewController+Timer.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

// MARK: - TimerServiceDelegate (Timer callbacks)

/// Handles timer update and completion callbacks to update UI, play feedback,
/// and persist daily stats when appropriate.
extension PomodoroViewController: TimerServiceDelegate {
    
    /// Updates the timer label text and progress ring colorized by the current mode.
    /// - Parameters:
    ///   - timeString: Formatted time remaining (MM:SS).
    ///   - progress: 0...1 progress for the ring.
    func timerDidUpdate(timeString: String, progress: CGFloat) {
        mainView.updateTimerLabel(text: timeString)
        mainView.updateProgress(progress: progress, color: currentState.themeColor)
    }
    
    /// Handles timer completion: reset session state, play feedback, update stats, and reset UI.
    func timerDidFinish() {
        // Session is no longer active
        isSessionStarted = false
        
        // User feedback (haptics, sound) and visual flash
        NotificationService.shared.playCompletionHaptics()
        NotificationService.shared.playSound()
        mainView.flashScreen(color: currentState.themeColor)
        
        // Persistence: Only increment stats for completed focus sessions
        if currentState == .focus {
            PersistenceService.shared.incrementSessionCount()
            mainView.updateStats(count: PersistenceService.shared.dailyCompletedSessions)
        }
        
        // Reset primary action button to START
        mainView.updateStartButton(
            title: "START",
            color: DesignSystem.Colors.black ?? .black,
            titleColor: .white
        )
    }
}
