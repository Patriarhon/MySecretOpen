//
//  RoundedShadownButton.swift
//  My Secret
//
//  Created by Petr on 19.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

class RoundedShadownButton: UIButton {
    
    private var shadowLayer: CAShapeLayer!

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.size.height / 2).cgPath
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
