//
//  ModeSelectionView.swift
//  My Secret
//
//  Created by Petr on 04.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

protocol AuthWayViewDelegate: class {
    func didChange(modeNumber: Int)
}

class AuthWayView: NibView {
    var modeNumber = 0 {
        didSet {
            delegate?.didChange(modeNumber: modeNumber)
        }
    }
    
    weak var delegate: AuthWayViewDelegate?
    
    @IBOutlet var modeButtons: [UIButton]!
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet var indicatorCenterXConstraints: [NSLayoutConstraint]!
    @IBOutlet var indicatorWidthConstraints: [NSLayoutConstraint]!
    
    @IBAction func didTapModeButton(_ sender: UIButton) {
        guard !sender.isSelected else { return }
        
        for button in modeButtons.enumerated() {
            let isActive = button.element == sender
            button.element.isSelected = isActive
            layoutIfNeeded()
            indicatorWidthConstraints[button.offset].isActive = isActive
            indicatorCenterXConstraints[button.offset].isActive = isActive
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
            
            if isActive {
                modeNumber = button.offset
            }
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        modeButtons[0].setTitle("phoneButton".localized(), for: .normal)
        modeButtons[1].setTitle("emailButton".localized(), for: .normal)
        
        for button in modeButtons {
            button.titleLabel?.font = UIFont.getFont(font: .sfProTextRegular, size: 14)
        }
    }
}

