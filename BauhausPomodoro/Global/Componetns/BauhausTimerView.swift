//
//  BauhausTimerView.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

final class BauhausTimerView: UIView {
    
    private let shapeLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    
    let timerLabel: UILabel = {
        let label = UILabel()
        label.text = "25:00"
        label.font = DesignSystem.Typography.boldFont(size: 70)
        label.textColor = DesignSystem.Colors.black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createCircularPath()
    }
    
    private func createCircularPath() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        let circularPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        // Avoid duplicating sublayers on repeated layout passes
        if trackLayer.superlayer == nil { layer.addSublayer(trackLayer) }
        if shapeLayer.superlayer == nil { layer.addSublayer(shapeLayer) }
        
        trackLayer.path = circularPath.cgPath
        let trackColor = (DesignSystem.Colors.black ?? UIColor.black).withAlphaComponent(0.1)
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 20
        trackLayer.fillColor = UIColor.clear.cgColor
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = (DesignSystem.Colors.red ?? UIColor.red).cgColor
        shapeLayer.lineWidth = 20
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .square 
        shapeLayer.strokeEnd = 0
    }
    
    func updateProgress(_ percentage: CGFloat, color: UIColor) {
        shapeLayer.strokeEnd = percentage
        shapeLayer.strokeColor = color.cgColor
    }
}
