//
//  RoundedShadowLabel.swift
//  My Secret
//
//  Created by Petr on 10.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

class RoundedShadowView: UIView {
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        layoutView()
    }
    
    private func layoutView() {
        backgroundColor = UIColor.init(named: "White")
        layer.cornerRadius = 8
        layer.shadowOpacity = 1
        layer.shadowRadius = 8.0
        layer.shadowOffset = CGSize(width: 1, height: 3)// Use any CGSize
        layer.shadowColor = UIColor.init(named: "Shadow")?.cgColor
    }
}
