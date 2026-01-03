//
//  BauhausTaskCell.swift
//  BauhausPomodoro
//
//  Created by Mert Aydogan on 03.01.2026.
//

import UIKit

class BauhausTaskCell: UITableViewCell {
    static let identifier = "BauhausTaskCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 3
        view.layer.borderColor = DesignSystem.Colors.black.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystem.Typography.mediumFont(size: 18)
        label.textColor = DesignSystem.Colors.black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let arrowIcon: UILabel = {
        let label = UILabel()
        label.text = "▶"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = DesignSystem.Colors.blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with task: Task) {
        titleLabel.text = task.title
        containerView.backgroundColor = task.isCompleted ? DesignSystem.Colors.background : .white
        titleLabel.textColor = task.isCompleted ? .gray : DesignSystem.Colors.black
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(arrowIcon)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 15),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            arrowIcon.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            arrowIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.1) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.98, y: 0.98) : .identity
            self.containerView.backgroundColor = highlighted ? DesignSystem.Colors.yellow : .white
        }
    }
}
