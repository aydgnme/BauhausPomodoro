//
//  ViewController.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .bauhausOffWhite
        title = "POMODORO"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        createTimerShape()
        setupUI()
    }
    
    // Timer
    var timer = Timer()
    var duration = 1500 // 25 minutes (sec)
    var isTimerRunning = false
    
    // UI Elements
    let timerLabel = UILabel()
    let actionButton = UIButton()
    let shapeLayer = CAShapeLayer()
    
    private func createTimerShape() {
        let center = view.center
        let circularPath = UIBezierPath(arcCenter: center, radius: 120, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        trackLayer.lineWidth = 15
        trackLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(trackLayer)
        
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.bauhausRed.cgColor
        shapeLayer.lineWidth = 15
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .square
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }
    
    private func setupUI() {
        // Timer Label
        timerLabel.text = "25:00"
        timerLabel.font = .systemFont(ofSize: 70, weight: .black)
        timerLabel.textColor = .bauhausBlack
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)
        
        actionButton.setTitle("START", for: .normal)
        actionButton.backgroundColor = .bauhausBlue
        actionButton.setTitleColor(.bauhausOffWhite, for: .normal)
        actionButton.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        actionButton.layer.cornerRadius = 0
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        view.addSubview(actionButton)
        
        // Constraints (Auto Layout)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 200),
            actionButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func startTimer() {
        if isTimerRunning {
            timer.invalidate()
            actionButton.setTitle("RESUME", for: .normal)
            actionButton.backgroundColor = .bauhausYellow
            actionButton.setTitleColor(.bauhausBlack, for: .normal)
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if self.duration > 0 {
                    self.duration -= 1
                    self.updateUI()
                } else {
                    self.timer.invalidate()
                }
            }
            actionButton.setTitle("PAUSE", for: .normal)
            actionButton.backgroundColor = .bauhausBlue
            actionButton.setTitleColor(.bauhausOffWhite, for: .normal)
        }
        isTimerRunning.toggle()
    }

    func updateUI() {
        let minutes = duration / 60
        let seconds = duration % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
        
        let totalTime: CGFloat = 1500
        let percentage = CGFloat(totalTime - CGFloat(duration)) / totalTime
        shapeLayer.strokeEnd = percentage
    }
}

