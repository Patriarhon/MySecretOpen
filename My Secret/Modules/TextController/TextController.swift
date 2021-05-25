//
//  TextController.swift
//  My Secret
//
//  Created by Petr on 19.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

enum TextType {
    case terms
    case privacy
}

class TextController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var type: TextType!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch type {
        case .terms:
            titleLabel.text = "terms of use".localized()
            textView.text = "terms".localized()
        case .privacy:
            titleLabel.text = "privacy policy".localized()
            textView.text = "privacy".localized()
        case .none:
            break
        }
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
