//
//  PhoneRoundedShadowTextField.swift
//  My Secret
//
//  Created by Petr on 06.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import PhoneNumberKit

class PhoneTextField: PhoneNumberTextField {
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        layoutView()
    }
    
    private func layoutView() {
        
        //Basic texfield Setup
        borderStyle = .none
        backgroundColor = UIColor.init(named: "White")
        
        //To apply corner radius
        layer.cornerRadius = 8
        
        //To apply border
        //        layer.borderWidth = 0.25
        //        layer.borderColor = UIColor.white.cgColor
        
        //To apply Shadow
        layer.shadowOpacity = 1
        layer.shadowRadius = 8.0
        layer.shadowOffset = CGSize(width: 1, height: 3)// Use any CGSize
        layer.shadowColor = UIColor.init(named: "Shadow")?.cgColor
        
        //To apply padding
        let paddingView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: frame.height))
        leftView = paddingView
        leftViewMode = UITextField.ViewMode.always
        
        font = UIFont.getFont(font: .sfProTextRegular, size: 14)
    }
}
