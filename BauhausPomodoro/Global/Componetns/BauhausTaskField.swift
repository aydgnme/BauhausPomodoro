//
//  BauhausTaskField.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

class BauhausTaskField: UIView {

    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "WRITE TASK..."
        tf.font = DesignSystem.Typography.mediumFont(size: 16)
        tf.textAlignment = .center
        tf.backgroundColor = .clear
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setText(_ text: String) {
        textField.text = text
    }
    func getText() -> String? {
        return textField.text
    }
    
    private func setupView() {
            backgroundColor = .white
            layer.borderWidth = 3
            layer.borderColor = (DesignSystem.Colors.black ?? .black).cgColor
            
            addSubview(textField)
            NSLayoutConstraint.activate([
                textField.topAnchor.constraint(equalTo: topAnchor),
                textField.bottomAnchor.constraint(equalTo: bottomAnchor),
                textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
                textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
            ])
        }
        
        required init?(coder: NSCoder) { fatalError() }
}

