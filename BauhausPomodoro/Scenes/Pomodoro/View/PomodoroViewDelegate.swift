//
//  PomodoroViewDelegate.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import Foundation

protocol PomodoroViewDelegate: AnyObject {
    func didTapStartButton()
    func didTapModeButton(title: String)
}
