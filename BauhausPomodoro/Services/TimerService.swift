//
//  TimerService.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import Foundation

protocol TimerServiceDelegate: AnyObject {
    func timerDidUpdate(timeString: String, progress: CGFloat)
    func timerDidFinish()
}

final class TimerService {
    weak var delegate: TimerServiceDelegate?
    private var timer: Timer?
    private var duration: Int = 0
    private var totalTime: Int = 0
    
    func start(minutes: Int) {
        duration = minutes * 60
        totalTime = duration
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.duration > 0 {
                self.duration -= 1
                let percentage = CGFloat(self.totalTime - self.duration) / CGFloat(self.totalTime)
                self.delegate?.timerDidUpdate(timeString: self.formatTime(), progress: percentage)
            } else {
                self.timer?.invalidate()
                self.delegate?.timerDidFinish()
            }
        }
    }
    
    func pause() { timer?.invalidate() }
    
    private func formatTime() -> String {
        let mins = duration / 60
        let secs = duration % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
