//
//  ButtonCell.swift
//  My Secret
//
//  Created by Petr on 30.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

protocol ButtonCellDelegate: class {
    func didTapButton()
}

class ButtonCell: UITableViewCell {

    @IBOutlet weak var button: MainButton!
    
    weak var delegate: ButtonCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        button.setTitle("search".localized(), for: .normal)
    }

    @IBAction func buttonAction(_ sender: Any) {
        delegate?.didTapButton()
    }
    
    func setButtonState(isEnabled: Bool) {
        button.isEnabled = isEnabled
    }
}
