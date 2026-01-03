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
        
        static let subTaskMap = "subTaskMap"
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
    
    
    // MARK: - Sub-Task Logic
    func saveSubTask(_ subTask: String, for mainTaskId: UUID) {
        var map = defaults.dictionary(forKey: Keys.subTaskMap) as? [String: String] ?? [:]
        map[mainTaskId.uuidString] = subTask
        defaults.set(map, forKey: Keys.subTaskMap)
    }
    
    func getLastSubTask(for mainTaskId: UUID) -> String? {
        let map = defaults.dictionary(forKey: Keys.subTaskMap) as? [String: String] ?? [:]
        return map[mainTaskId.uuidString]
    }
    
    func logCompletedSession(mainTask: String, subTask: String?) {
        print("LOG: Main: \(mainTask) | Sub: \(subTask ?? "Main Focus") | Date: \(Date())")
        incrementSessionCount()
    }
}
