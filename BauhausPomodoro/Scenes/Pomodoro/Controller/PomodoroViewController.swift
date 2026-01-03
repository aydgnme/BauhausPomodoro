//
//  PomodoroViewController.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

enum PomodoroState {
    case focus
    case shortBreak
    case longBreak

    var duration: Int { // seconds
        switch self {
        case .focus: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        }
    }

    var themeColor: UIColor {
        switch self {
        case .focus:
            return DesignSystem.Colors.red ?? .systemRed
        case .shortBreak:
            return DesignSystem.Colors.blue ?? .systemBlue
        case .longBreak:
            return DesignSystem.Colors.yellow ?? .systemYellow
        }
    }
}

final class PomodoroViewController: UIViewController {
    
    // MARK: - Properties
    private let timerService = TimerService()
    private var currentState: PomodoroState = .focus
    
    // MARK: - UI Components
    private let timerView = BauhausTimerView()
    
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
            startButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupModeButtons() {
        let modes: [(String, PomodoroState)] = [("FOCUS", .focus), ("SHORT", .shortBreak), ("LONG", .longBreak)]
        
        for mode in modes {
            let btn = UIButton(type: .system)
            btn.setTitle(mode.0, for: UIControl.State.normal)
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
        timerService.start(minutes: currentState.duration / 60)
        startButton.setTitle("PAUSE", for: UIControl.State.normal)
        startButton.backgroundColor = (DesignSystem.Colors.black ?? .black)
    }
    
    @objc private func changeMode(_ sender: UIButton) {
        guard let title = sender.currentTitle else { return }
        switch title {
        case "FOCUS": currentState = PomodoroState.focus
        case "SHORT": currentState = PomodoroState.shortBreak
        default: currentState = PomodoroState.longBreak
        }
        
        timerView.timerLabel.text = String(format: "%02d:00", currentState.duration / 60)
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
        // Call Notification Services
        NotificationService.shared.playCompletionHaptics()
        NotificationService.shared.playSound()
        
        // Virsual Effects
        flashScreen()
        
        startButton.setTitle("COMPLETED", for: .normal)
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
