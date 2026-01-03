//
//  BauhausButton.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

final class BauhausButton: UIButton {
    
    init(title: String, color: UIColor) {
        super.init(frame: .zero)
        self.setTitle(title, for: .normal)
        self.backgroundColor = color
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = DesignSystem.Typography.mediumFont(size: 18)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.borderWidth = 3
        self.layer.borderColor = (DesignSystem.Colors.black ?? .black).cgColor
        self.layer.cornerRadius = 8
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

