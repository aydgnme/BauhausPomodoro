//
//  Task.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import Foundation

struct Task {
    let id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var completedSessions: Int = 0
}
