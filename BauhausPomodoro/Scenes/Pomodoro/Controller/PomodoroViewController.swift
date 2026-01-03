//
//  PomodoroViewController.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

final class PomodoroViewController: UIViewController {
    
    // MARK: - Properties
    private let timerService = TimerService()
    private var currentState: PomodoroState = .focus
    private var isSessionStarted = false
    
    // MARK: - UI Components
    private let timerView = BauhausTimerView()
    private let taskField = BauhausTaskField()
    
    private let startButton = BauhausButton(title: "START", color: (DesignSystem.Colors.red ?? .systemRed))
    
    private let modeStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 0
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.layer.borderWidth = 3
        sv.layer.borderColor = (DesignSystem.Colors.black ?? .black).cgColor
        return sv
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTimerService()
    }
    
    private func setupUI() {
        view.backgroundColor = DesignSystem.Colors.background
        title = "BAUHAUS FOCUS"
        
        timerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerView)
        
        // Mode Buttons
        setupModeButtons()
        view.addSubview(modeStackView)
        
        // Start Button
        view.addSubview(startButton)
        startButton.addTarget(self, action: #selector(handleStart), for: .touchUpInside)
        
        // Task Field
        taskField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taskField)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            // Mode Stack
            modeStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            modeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            modeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            modeStackView.heightAnchor.constraint(equalToConstant: 50),
            
            // Timer View
            timerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            timerView.widthAnchor.constraint(equalToConstant: 250),
            timerView.heightAnchor.constraint(equalToConstant: 250),
            
            // Start Button
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            
            taskField.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 30),
                taskField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                taskField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                taskField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupModeButtons() {
        let modes: [PomodoroState] = [
            .shortBreak, .longBreak, .focus
        ]
        
        for mode in modes {
            let btn = UIButton(type: .system)
            btn.setTitle(mode.title, for: UIControl.State.normal)
            btn.backgroundColor = (DesignSystem.Colors.black ?? .black)
            btn.setTitleColor(.white, for: UIControl.State.normal)
            btn.titleLabel?.font = DesignSystem.Typography.mediumFont(size: 14)
            btn.addTarget(self, action: #selector(changeMode(_:)), for: UIControl.Event.touchUpInside)
            modeStackView.addArrangedSubview(btn)
        }
    }
    
    private func configureTimerService() {
        timerService.delegate = self
    }
    
    // MARK: - Actions
    @objc private func handleStart() {
        if timerService.isTimerRunning {
            
            timerService.pause()
            startButton.setTitle("RESUME", for: .normal)
            startButton.backgroundColor = DesignSystem.Colors.yellow
            startButton.setTitleColor(.bauhausBlack, for: .normal)
        } else {
            if isSessionStarted {
                timerService.resume()
            } else {
                timerService.startNewSession(minutes: currentState.duration / 60)
                isSessionStarted = true
            }
            
            startButton.setTitle("PAUSE", for: .normal)
                        startButton.backgroundColor = currentState.themeColor
                        startButton.setTitleColor(.bauhausOffWhite, for: .normal)
        }
    }
    
    @objc private func changeMode(_ sender: UIButton) {
            timerService.stop()
            isSessionStarted = false
            
            guard let title = sender.currentTitle else { return }
            
            switch title {
            case "FOCUS": currentState = .focus
            case "SHORT": currentState = .shortBreak
            default: currentState = .longBreak
            }
            
            timerView.timerLabel.text = String(format: "%02d:00", currentState.duration / 60)
            timerView.updateProgress(0, color: currentState.themeColor)
            
            startButton.setTitle("START", for: .normal)
            startButton.backgroundColor = currentState.themeColor
            
            modeStackView.arrangedSubviews.forEach { $0.alpha = 0.5 }
            sender.alpha = 1.0
        }
}

// MARK: - TimerServiceDelegate
extension PomodoroViewController: TimerServiceDelegate {
    func timerDidUpdate(timeString: String, progress: CGFloat) {
        timerView.timerLabel.text = timeString
        timerView.updateProgress(progress, color: currentState.themeColor)
    }
    
    func timerDidFinish() {
        isSessionStarted = false
        
        NotificationService.shared.playCompletionHaptics()
        NotificationService.shared.playSound()
        flashScreen()
        
        startButton.setTitle("START", for: .normal)
        startButton.backgroundColor = DesignSystem.Colors.black
    }
    
    private func flashScreen() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = self.currentState.themeColor
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                self.view.backgroundColor = DesignSystem.Colors.background
            }
        }
    }
}

