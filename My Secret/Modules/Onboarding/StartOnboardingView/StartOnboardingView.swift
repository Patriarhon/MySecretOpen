//
//  StartOnboardingView.swift
//  My Secret
//
//  Created by Petr on 17.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

class StartOnboardingView: NibView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        titleLabel.text = "step1Title".localized()
        subtitleLabel.text = "step1Subtitle".localized()
    }
}
