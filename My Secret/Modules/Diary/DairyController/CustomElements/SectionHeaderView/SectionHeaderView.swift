//
//  SectionHeaderView.swift
//  My Secret
//
//  Created by Petr on 17.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

class SectionHeaderView: NibView {

    @IBOutlet weak var label: UILabel!
    
    func setTitle(_ title: String) {
        label.font = UIFont.getFont(font: .sintonyRegular, size: 14)
        label.text = title
//        let attributes = [
//            .font: UIFont.getFont(font: .sintonyBold, size: 16),
//            .underlineStyle: NSUnderlineStyle.single.rawValue,
//            .underlineColor: Palette.orange
//            ] as [NSAttributedString.Key : Any]
//
//        label.attributedText = NSAttributedString(string: title, attributes: attributes)
    }
}
