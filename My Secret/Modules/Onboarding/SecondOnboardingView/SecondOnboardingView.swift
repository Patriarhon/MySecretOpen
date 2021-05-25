//
//  SecondOnboardingView.swift
//  My Secret
//
//  Created by Petr on 17.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

protocol SecondOnboardingViewDelegate: class {
    func didTapBegin()
}

class SecondOnboardingView: NibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var beginButton: MainButton!
    
    weak var delegate: SecondOnboardingViewDelegate?
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        titleLabel.text = "step3Title".localized()
        subtitleLabel.text = "step3Subtitle".localized()
        
        beginButton.setTitle("begin".localized(), for: .normal)
    }
    @IBAction func beginButtonAction(_ sender: Any) {
        delegate?.didTapBegin()
    }
}
