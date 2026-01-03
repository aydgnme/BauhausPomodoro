//
//  PomodoroRootView.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

/// PomodoroRootView
/// Custom root view for the Pomodoro screen. Hosts the timer view, mode selector,
/// task input, start button, and daily stats label. Forwards user actions to its delegate.
final class PomodoroRootView: UIView {
    
    // MARK: - Delegate
    /// Notifies the controller about user interactions (start/mode taps).
    weak var delegate: PomodoroViewDelegate?
    
    // MARK: - UI Components
    /// Circular timer with progress ring and time label.
    let timerView = BauhausTimerView()
    /// Text field for entering the current task.
    let taskField = BauhausTaskField()
    /// Primary action button controlling start/pause/resume.
    private let startButton = BauhausButton(title: "START", color: (DesignSystem.Colors.red ?? .systemRed))
    
    private let modeStackView: UIStackView = {
        let sv = UIStackView()
        // Horizontal segmented-like control for FOCUS / SHORT / LONG
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 0
        sv.layer.borderWidth = 3
        sv.layer.borderColor = (DesignSystem.Colors.black ?? .black).cgColor
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    /// Displays today's completed focus sessions.
    private let statsLabel: UILabel = {
        let label = UILabel()
        label.text = "TODAY: 0"
        label.font = DesignSystem.Typography.mediumFont(size: 14)
        label.textColor = (DesignSystem.Colors.black ?? .black).withAlphaComponent(0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Init
    /// Initializes and builds the view hierarchy.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupModeButtons()
    }
    
    /// Unavailable. Use programmatic initialization.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Setup UI
    /// Creates subviews, wires actions, and applies Auto Layout constraints.
    private func setupUI() {
        backgroundColor = DesignSystem.Colors.background
        
        // Disable autoresizing masks for Auto Layout
        timerView.translatesAutoresizingMaskIntoConstraints = false
        taskField.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        addSubview(timerView)
        addSubview(modeStackView)
        addSubview(startButton)
        addSubview(taskField)
        addSubview(statsLabel)
        
        // Wire start button tap to delegate
        startButton.addTarget(self, action: #selector(handleStartTap), for: .touchUpInside)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Mode selector
            modeStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            modeStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            modeStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            modeStackView.heightAnchor.constraint(equalToConstant: 50),
            
            // Center timer view
            timerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            timerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            timerView.widthAnchor.constraint(equalToConstant: 250),
            timerView.heightAnchor.constraint(equalToConstant: 250),
            
            // Bottom action button
            startButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -40),
            startButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 200),
            startButton.heightAnchor.constraint(equalToConstant: 60),
            
            // Task input
            taskField.topAnchor.constraint(equalTo: timerView.bottomAnchor, constant: 30),
            taskField.centerXAnchor.constraint(equalTo: centerXAnchor),
            taskField.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            taskField.heightAnchor.constraint(equalToConstant: 50),
            
            // Daily stats
            statsLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            statsLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    // MARK: - Setup Mode Buttons
    /// Builds the three mode buttons and wires up tap handling.
    private func setupModeButtons() {
        // Display order
        let modes = ["SHORT", "LONG", "FOCUS"]
        for title in modes {
            // Configure segment-like button
            let btn = UIButton(type: .system)
            btn.setTitle(title, for: .normal)
            btn.backgroundColor = (DesignSystem.Colors.black ?? .black)
            btn.setTitleColor(.white, for: .normal)
            btn.titleLabel?.font = DesignSystem.Typography.mediumFont(size: 14)
            btn.addTarget(self, action: #selector(handleModeTap(_:)), for: .touchUpInside)
            modeStackView.addArrangedSubview(btn)
        }
    }
    
    // MARK: - Public Methods
    
    /// Updates the timer label with a formatted string.
    /// - Parameter text: Formatted time string (MM:SS).
    func updateTimerLabel(text: String) {
        timerView.timerLabel.text = text
    }
    
    /// Updates the circular progress and applies a theme color.
    /// - Parameters:
    ///   - progress: 0...1 progress value.
    ///   - color: Theme color to tint the progress view.
    func updateProgress(progress: CGFloat, color: UIColor) {
        timerView.updateProgress(progress, color: color)
    }
    
    /// Displays the number of completed focus sessions today.
    /// - Parameter count: Daily completed session count.
    func updateStats(count: Int) {
        statsLabel.text = "TODAY: \(count)"
    }
    
    /// Updates the start button's title and colors.
    /// - Parameters:
    ///   - title: Button title.
    ///   - color: Background color.
    ///   - titleColor: Title color.
    func updateStartButton(title: String, color: UIColor, titleColor: UIColor) {
        startButton.setTitle(title, for: .normal)
        startButton.backgroundColor = color
        startButton.setTitleColor(titleColor, for: .normal)
    }
    
    /// Highlights the mode button matching the provided title.
    /// - Parameter title: One of "FOCUS", "SHORT", or "LONG".
    func highlightMode(title: String) {
        modeStackView.arrangedSubviews.forEach { ($0 as? UIButton)?.alpha = 0.5 }
        if let btn = modeStackView.arrangedSubviews.first(where: { ($0 as? UIButton)?.currentTitle == title }) {
            btn.alpha = 1.0
        }
    }
    
    /// Briefly flashes the background with the given color, then restores the default.
    /// - Parameter color: The color to flash.
    func flashScreen(color: UIColor) {
        UIView.animate(withDuration: 0.2, animations: {
            self.backgroundColor = color
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                self.backgroundColor = DesignSystem.Colors.background
            }
        }
    }
    
    // MARK: - Actions
    /// Forwards start button tap to the delegate.
    @objc private func handleStartTap() {
        delegate?.didTapStartButton()
    }
    
    /// Forwards mode button tap to the delegate using the button's title.
    /// - Parameter sender: The tapped mode button.
    @objc private func handleModeTap(_ sender: UIButton) {
        // Safely unwrap the title
        guard let title = sender.currentTitle else { return }
        delegate?.didTapModeButton(title: title)
    }
}

