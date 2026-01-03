//
//  TaskListViewController.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

/// TaskListViewController
/// Displays a list of tasks with the ability to add new ones and navigate
/// to a Pomodoro session for a selected task.
final class TaskListViewController: UIViewController {
    
    // MARK: - Properties
    /// In-memory list backing the table view. New tasks are inserted at the top.
    private var tasks: [Task] = []
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tv = UITableView()
            // List of tasks with custom Bauhaus styling
        tv.backgroundColor = DesignSystem.Colors.background
        tv.separatorStyle = .none
        tv.register(BauhausTaskCell.self, forCellReuseIdentifier: BauhausTaskCell.identifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    /// Text field to enter a new task title.
    private let taskInputView = BauhausTaskField()
    
    /// Primary action button to add the entered task.
    private let addButton = BauhausButton(title: "ADD", color: DesignSystem.Colors.blue)
    
    // MARK: - Lifecycle
    /// Sets up UI, delegates, and seeds a couple of example tasks.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Build view hierarchy and constraints
        setupUI()
        // Wire up table view delegate/data source
        setupDelegates()
        
        // Seed sample tasks (can be removed in production)
        tasks.append(Task(title: "Create Design System"))
        tasks.append(Task(title: "Write Timer Logic"))
    }
    
    // MARK: - Setup
    /// Configures appearance and layout for the input, button, and table view.
    private func setupUI() {
        // Background and navigation title
        view.backgroundColor = DesignSystem.Colors.background
        title = "TASKS"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(taskInputView)
        view.addSubview(addButton)
        view.addSubview(tableView)
        
        taskInputView.translatesAutoresizingMaskIntoConstraints = false
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Task input field
            taskInputView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            taskInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taskInputView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65),
            taskInputView.heightAnchor.constraint(equalToConstant: 50),
            // Add button
            addButton.topAnchor.constraint(equalTo: taskInputView.topAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.leadingAnchor.constraint(equalTo: taskInputView.trailingAnchor, constant: 10),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            // Tasks table
            tableView.topAnchor.constraint(equalTo: taskInputView.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Handle add action
        addButton.addTarget(self, action: #selector(addTask), for: .touchUpInside)
    }
    
    /// Assigns table view delegate and data source.
    private func setupDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Actions
    /// Reads text input, creates a new task at the top, updates the table, and clears input.
    @objc private func addTask() {
        // Validate non-empty input
        guard let text = taskInputView.getText(), !text.isEmpty else { return }
        // Create new task model
        let newTask = Task(title: text)
        // Insert at top for most-recent-first order
        tasks.insert(newTask, at: 0)
        // Animate insertion
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        // Clear input
        taskInputView.setText("")
        // Dismiss keyboard
        view.endEditing(true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    /// Number of tasks to display.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    /// Dequeues and configures a BauhausTaskCell for the given index path.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BauhausTaskCell.identifier, for: indexPath) as? BauhausTaskCell else {
            return UITableViewCell()
        }
        cell.configure(with: tasks[indexPath.row])
        return cell
    }
    
    /// Fixed row height for consistent layout.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    /// Navigates to Pomodoro screen for the selected task (dependency injection).
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Retrieve model
        let selectedTask = tasks[indexPath.row]
        // Inject selected task into Pomodoro screen
        let pomodoroVC = PomodoroViewController(task: selectedTask) // Dependency Injection
        // Push detail controller
        navigationController?.pushViewController(pomodoroVC, animated: true)
    }
}
