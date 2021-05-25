//
//  VoiceHeaderView.swift
//  My Secret
//
//  Created by Petr on 21.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

class VoiceHeaderView: NibView {
    
        @IBOutlet weak var label: UILabel!
        
        func setTitle(_ title: String) {
            label.font = UIFont.getFont(font: .sfProTextMedium, size: 16)
            label.text = title
        }
}
