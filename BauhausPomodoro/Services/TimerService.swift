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
    private var remainingTime: Int = 0
    private var totalTime: Int = 0
    
    var isTimerRunning: Bool {
        return timer != nil
    }
    
    func startNewSession(minutes: Int) {
        stop()
        
        totalTime = minutes * 60
        remainingTime = totalTime
        
        startTimer()
    }
    
    func resume() {
        if remainingTime > 0 && timer == nil {
            startTimer()
        }
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        remainingTime = 0
        totalTime = 0
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
                
                let progress = CGFloat(self.totalTime - self.remainingTime) / CGFloat(self.totalTime)
                
                self.delegate?.timerDidUpdate(timeString: self.formatTime(), progress: progress)
            } else {
                self.stop()
                self.delegate?.timerDidFinish()
            }
        }
    }
    private func formatTime() -> String {
        let mins = remainingTime / 60
        let secs = remainingTime % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
