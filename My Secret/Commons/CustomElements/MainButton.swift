//
//  DefaultButton.swift
//  My Secret
//
//  Created by Petr on 05.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

class MainButton: UIButton {
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        layer.cornerRadius = 8
        
        layer.masksToBounds = false
        
        layer.shadowOpacity = 1
        layer.shadowRadius = 8.0
        layer.shadowOffset = CGSize(width: 0, height: 4)// Use any CGSize
        layer.shadowColor = Palette.shadow.cgColor
        
        titleLabel?.font = UIFont.getFont(font: .sfProTextRegular, size: 14)
    }
    
    override public var isEnabled: Bool {
        didSet {
            if self.isEnabled {
                self.backgroundColor = Palette.darkBlue
            } else {
                self.backgroundColor = Palette.lightGray
            }
        }
    }
}
