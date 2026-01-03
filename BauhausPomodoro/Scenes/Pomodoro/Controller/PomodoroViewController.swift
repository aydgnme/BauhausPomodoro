//
//  PomodoroViewController.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

/// PomodoroViewController
/// Manages a Pomodoro session UI for a given `Task`.
/// Handles timer lifecycle (start/pause/resume/stop), mode switching (focus/short/long),
/// simple persistence for the last entered task and daily stats, and updates a custom
/// circular timer view.
final class PomodoroViewController: UIViewController {
    
    // MARK: - Dependencies & State

    // Incoming Task (Dependency Injection). Used to set the navigation title and context
    private let currentTask: Task

    // Services
    private let timerService = TimerService() // Controls timer ticking and delegates updates

    // Current UI/session state
    private var currentState: PomodoroState = .focus // Active mode; defaults to focus
    private var isSessionStarted = false // Tracks if a session has been started at least once
    
    // MARK: - Initialization
    /// Initializes the controller with a required `Task`.
    /// - Parameter task: The task context for this Pomodoro session.
    init(task: Task) {
        self.currentTask = task
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    
    // Circular timer with label + progress
    private let timerView = BauhausTimerView()
    
    // Input for current task text (persisted between sessions)
    private let taskField = BauhausTaskField()
    
    // Primary action button controlling start/pause/resume
    private let startButton = BauhausButton(title: "START", color: (DesignSystem.Colors.red ?? .systemRed))
    
    private let modeStackView: UIStackView = {
        let sv = UIStackView()
        // Horizontal segmented-like control for FOCUS / SHORT / LONG
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 0
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.layer.borderWidth = 3
        sv.layer.borderColor = (DesignSystem.Colors.black ?? .black).cgColor
        return sv
    }()
    
    /// Shows number of completed focus sessions today.
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.text = "TODAY: 0"
        label.font = DesignSystem.Typography.mediumFont(size: 14)
        label.textColor = (DesignSystem.Colors.black ?? .black).withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle
    /// Sets up view hierarchy, binds services, restores last task, and updates stats.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Build and layout subviews
        configureTimerService()
        // Bind timer delegate callbacks
        
        // Use task title for navigation
        title = currentTask.title.uppercased()
        
        // Restore last entered task text if available
        if let lastTask = PersistenceService.shared.getLastTask() {
            taskField.setText(lastTask)
        }
        // Refresh daily stats label
        updateStatsLabel()
    }
    
    /// Creates subviews, configures styles, and activates Auto Layout constraints.
    private func setupUI() {
        view.backgroundColor = DesignSystem.Colors.background
        
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
        view.addSubview(statsLabel)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            // Mode selector (FOCUS/SHORT/LONG)
            modeStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            modeStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            modeStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            modeStackView.heightAnchor.constraint(equalToConstant: 50),
            
            // Center timer view
            timerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            timerView.widthAnchor.constraint(equalToConstant: 250),
            timerView.heightAnchor.constraint(equalToConstant: 250),
            
            // Bottom primary action button
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Task input
            taskField.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 30),
            taskField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            taskField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            taskField.heightAnchor.constraint(equalToConstant: 50),
            
            // Daily stats label
            statsLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            statsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    /// Builds the three mode buttons and wires up the action handler.
    private func setupModeButtons() {
        // Display order: SHORT, LONG, FOCUS
        let modes: [PomodoroState] = [
            .shortBreak, .longBreak, .focus
        ]
        
        for mode in modes {
            // Configure a segment-like button
            let btn = UIButton(type: .system)
            btn.setTitle(mode.title, for: UIControl.State.normal)
            btn.backgroundColor = (DesignSystem.Colors.black ?? .black)
            btn.setTitleColor(.white, for: UIControl.State.normal)
            btn.titleLabel?.font = DesignSystem.Typography.mediumFont(size: 14)
            btn.addTarget(self, action: #selector(changeMode(_:)), for: UIControl.Event.touchUpInside)
            modeStackView.addArrangedSubview(btn)
        }
    }
    
    /// Assigns self as delegate to receive timer updates.
    private func configureTimerService() {
        timerService.delegate = self
    }
    
    // MARK: - Actions
    
    /// Toggles between start/pause/resume for the current session.
    /// Persists the task text when pausing.
    @objc private func handleStart() {
        if timerService.isTimerRunning {
            // Currently running -> pause
            timerService.pause()
            startButton.setTitle("RESUME", for: .normal)
            startButton.backgroundColor = DesignSystem.Colors.yellow
            startButton.setTitleColor(.bauhausBlack, for: .normal)
            if let task = taskField.getText(), !task.isEmpty {
                PersistenceService.shared.saveTask(task)
            }
        } else {
            // Was paused -> resume
            if isSessionStarted {
                timerService.resume()
            } else {
                // First start for this mode
                timerService.startNewSession(minutes: currentState.duration / 60)
                isSessionStarted = true
            }
            // Reflect running state in button UI
            startButton.setTitle("PAUSE", for: .normal)
            startButton.backgroundColor = currentState.themeColor
            startButton.setTitleColor(.bauhausOffWhite, for: .normal)
        }
    }
    
    /// Changes the Pomodoro mode based on tapped button title and resets UI/timer.
    /// - Parameter sender: The tapped mode button.
    @objc private func changeMode(_ sender: UIButton) {
        // Ensure any running timer is stopped
        timerService.stop()
        isSessionStarted = false
        
        // Determine target mode from button title
        guard let title = sender.currentTitle else { return }
        
        // Map button titles to internal state
        switch title {
        case "FOCUS": currentState = .focus
        case "SHORT": currentState = .shortBreak
        default: currentState = .longBreak
        }
        
        // Reset timer label and progress for new mode
        timerView.timerLabel.text = String(format: "%02d:00", currentState.duration / 60)
        timerView.updateProgress(0, color: currentState.themeColor)
        
        // Reset primary action button
        startButton.setTitle("START", for: .normal)
        startButton.backgroundColor = currentState.themeColor
        
        // Visually highlight selected mode
        modeStackView.arrangedSubviews.forEach { $0.alpha = 0.5 }
        sender.alpha = 1.0
    }
}

// MARK: - TimerServiceDelegate

extension PomodoroViewController: TimerServiceDelegate {
    /// Updates the timer label and progress ring as the timer ticks.
    func timerDidUpdate(timeString: String, progress: CGFloat) {
        timerView.timerLabel.text = timeString
        timerView.updateProgress(progress, color: currentState.themeColor)
    }
    
    /// Handles completion: haptics, sound, flash, stats increment, and UI reset.
    func timerDidFinish() {
        // Session is no longer active
        isSessionStarted = false
        
        // Notify user that the session ended
        NotificationService.shared.playCompletionHaptics()
        NotificationService.shared.playSound()
        flashScreen()
        
        // Only count completed focus sessions towards daily stats
        if currentState == .focus {
            PersistenceService.shared.incrementSessionCount()
            updateStatsLabel()
        }
        
        // Reset button to idle state
        startButton.setTitle("START", for: .normal)
        startButton.backgroundColor = DesignSystem.Colors.black
    }
    
    // MARK: - Helpers

    /// Briefly flashes the background with the current mode color to indicate completion.
    private func flashScreen() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.backgroundColor = self.currentState.themeColor
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                self.view.backgroundColor = DesignSystem.Colors.background
            }
        }
    }
    
    /// Reads the daily completed session count and updates the stats label.
    private func updateStatsLabel() {
        let count = PersistenceService.shared.dailyCompletedSessions
        statsLabel.text = "TODAY: \(count)"
    }
}

