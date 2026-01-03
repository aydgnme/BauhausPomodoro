//
//  PersistenceService.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import Foundation

final class PersistenceService {
    
    static let shared = PersistenceService()
    
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let dailySessionCount = "dailySessionCount"
        static let lastTask = "lastTask"
        static let lastDate = "lastDate"
    }
    
    private init() {}
    
    // MARK: - Public API
    
    var dailyCompletedSessions: Int {
        if !isSameDay() {
            resetDailyStats()
        }
        return defaults.integer(forKey: Keys.dailySessionCount)
    }
    
    func incrementSessionCount() {
        let current = dailyCompletedSessions
        defaults.set(current + 1, forKey: Keys.dailySessionCount)
        defaults.set(Date(), forKey: Keys.lastDate)
    }
    
    // Save Task
    func saveTask(_ task: String) {
        defaults.set(task, forKey: Keys.lastTask)
    }
    
    // Get Last Task
    func getLastTask() -> String? {
        return defaults.string(forKey: Keys.lastTask)
    }
    
    
    // MARK: - Helpers
    private func isSameDay() -> Bool {
        guard let lastDate = defaults.object(forKey: Keys.lastDate) as? Date else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
    
    private func resetDailyStats() {
        defaults.set(0, forKey: Keys.dailySessionCount)
        defaults.set(Date(), forKey: Keys.lastDate)
    }
}
