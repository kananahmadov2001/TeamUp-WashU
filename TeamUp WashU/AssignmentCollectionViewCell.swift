//
//  AssignmentCollectionViewCell.swift
//  TeamUp WashU
//
//  Created by Ahmadov, Kanan on 11/30/24.
//

import Foundation
import UIKit

class AssignmentCollectionViewCell: UICollectionViewCell {

    // Assignment button
    let assignmentButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.numberOfLines = 0 // Allow multiline text
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.backgroundColor = .black // Default color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        // Add the button to the cell's content view
        contentView.addSubview(assignmentButton)

        // Set up constraints for the button to fully fill the cell
        NSLayoutConstraint.activate([
            assignmentButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            assignmentButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            assignmentButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            assignmentButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])

        // Remove any border or corner styling from the cell since the button fills it
        self.layer.borderWidth = 0
        self.layer.cornerRadius = 0
        self.clipsToBounds = true
    }

    // Method to configure the cell
    func configure(title: String, backgroundColor: UIColor) {
        assignmentButton.setTitle(title, for: .normal)
        assignmentButton.backgroundColor = backgroundColor
    }
}
