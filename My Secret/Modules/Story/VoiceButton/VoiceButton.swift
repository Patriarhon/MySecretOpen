//
//  VoiceButton.swift
//  My Secret
//
//  Created by Petr on 28.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

class VoiceButton: UIButton {
    
    private var shadowLayer: CAShapeLayer!
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? Palette.orange : UIColor.clear
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: CGRect(x: 28, y: 28, width: 56, height: 56), cornerRadius: 28).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = Palette.shadow.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 1, height: 5)
            shadowLayer.shadowOpacity = 1
            shadowLayer.shadowRadius = 11

            layer.insertSublayer(shadowLayer, at: 0)
            //layer.insertSublayer(shadowLayer, below: nil) // also works
        }
    }
}

