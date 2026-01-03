//
//  PomodoroViewController.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

/// PomodoroViewController
/// Coordinates a Pomodoro session for a given Task using a custom root view (`PomodoroRootView`).
/// Manages timer lifecycle (start/pause/resume/stop), mode switching, simple persistence for
/// the last entered task, and daily stats.
final class PomodoroViewController: UIViewController {
    
    // MARK: - Dependencies & State
    /// The task context used for the title and session.
    private let currentTask: Task
    /// Service that drives timer updates and delegates back to this controller.
    let timerService = TimerService()
    
    /// Current mode (focus/short/long). Defaults to focus.
    var currentState: PomodoroState = .focus
    /// Tracks whether a session has been started at least once.
    var isSessionStarted = false

    /// Strongly-typed access to the controller's root view.
    var mainView: PomodoroRootView {
        return view as! PomodoroRootView
    }
    
    // MARK: - Initialization
    /// Initializes the controller with a required task.
    /// - Parameter task: The task to run a Pomodoro session for.
    init(task: Task) {
        self.currentTask = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    /// Sets the controller's root view to a `PomodoroRootView` instance.
    override func loadView() {
        view = PomodoroRootView()
    }
    
    /// Binds services and configures the initial view state.
    override func viewDidLoad() {
        super.viewDidLoad()
        configureServices()
        configureView()
    }
    
    // MARK: - Configuration
    /// Assigns delegates for timer updates and user interaction from the custom view.
    private func configureServices() {
        timerService.delegate = self
        mainView.delegate = self
    }
    
    /// Applies initial UI content (title, last task, stats) and resets UI to current mode.
    private func configureView() {
        // Use task title as navigation title
        title = currentTask.title.uppercased()
        
        // Restore last entered task if available
        if let lastTask = PersistenceService.shared.getLastTask() {
            mainView.taskField.setText(lastTask)
        }
        // Show today's completed focus sessions
        mainView.updateStats(count: PersistenceService.shared.dailyCompletedSessions)
        
        resetUIToCurrentState()
    }
    
    /// Resets timer label, progress, start button, and mode highlight to match `currentState`.
    func resetUIToCurrentState() {
        // Reset timer label to full minutes
        mainView.updateTimerLabel(text: String(format: "%02d:00", currentState.duration / 60))
        // Clear progress with current theme color
        mainView.updateProgress(progress: 0, color: currentState.themeColor)
        
        // Set start button to default START state
        mainView.updateStartButton(
            title: "START",
            color: currentState.themeColor,
            titleColor: .bauhausOffWhite
        )
        // Highlight the active mode in the UI
        mainView.highlightMode(title: currentState.title)
    }
}

// MARK: - User Actions (View Delegate)
extension PomodoroViewController: PomodoroViewDelegate {
    
    /// Toggles between pause/resume/start depending on current timer state.
    /// Persists the task text when pausing.
    func didTapStartButton() {
        if timerService.isTimerRunning {
            // Currently running -> pause
            timerService.pause()
            // Reflect paused state
            mainView.updateStartButton(
                title: "RESUME",
                color: DesignSystem.Colors.yellow ?? .yellow,
                titleColor: .black
            )
            
            if let task = mainView.taskField.getText(), !task.isEmpty {
                PersistenceService.shared.saveTask(task)
            }
        } else {
            // Decide between resume or first start
            if isSessionStarted {
                // Resume ticking
                timerService.resume()
            } else {
                // First start for this mode
                timerService.startNewSession(minutes: currentState.duration / 60)
                isSessionStarted = true
            }
            
            // Reflect running state
            mainView.updateStartButton(
                title: "PAUSE",
                color: currentState.themeColor,
                titleColor: .white
            )
        }
    }
    
    /// Changes the current mode based on tapped title and resets UI/timer.
    /// - Parameter title: Button title (FOCUS/SHORT/LONG).
    func didTapModeButton(title: String) {
        // Stop any running timer before switching
        timerService.stop()
        isSessionStarted = false
        
        // Map title to internal mode enum
        switch title {
        case "FOCUS": currentState = .focus
        case "SHORT": currentState = .shortBreak
        default: currentState = .longBreak
        }
        
        // Refresh UI to reflect the new mode
        resetUIToCurrentState()
    }
}

