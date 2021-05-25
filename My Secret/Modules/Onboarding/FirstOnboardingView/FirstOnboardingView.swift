//
//  FirstOnboardingView.swift
//  My Secret
//
//  Created by Petr on 17.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

class FirstOnboardingView: NibView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        titleLabel.text = "step2Title".localized()
        subtitleLabel.text = "step2Subtitle".localized()
    }
}
