//
//  FloatingMenuButton.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 02.11.2026.
//

import UIKit

public final class FloatingMenuButton: UIButton {
    
    public init(iconSystemName: String) {
        super.init(frame: .zero)
        setup(iconSystemName: iconSystemName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(iconSystemName: String) {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        setImage(UIImage(systemName: iconSystemName, withConfiguration: symbolConfig), for: .normal)
        tintColor = .white
        backgroundColor = .appAccent
        
        layer.cornerRadius = Constants.Layout.floatingButtonSize / 2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        
        showsMenuAsPrimaryAction = true
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: Constants.Layout.floatingButtonSize),
            heightAnchor.constraint(equalToConstant: Constants.Layout.floatingButtonSize)
        ])
    }
}
