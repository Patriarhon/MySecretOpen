//
//  HeadingSearchCell.swift
//  My Secret
//
//  Created by Petr on 28.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

protocol HeadingSearchCellDelegate: class {
    func headingSwitchChanged(isOn: Bool)
    func textFieldChanged(text: String)
    func textFieldDone()
}

class HeadingSearchCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    weak var delegate: HeadingSearchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = "search by heading".localized()

        textField.layer.cornerRadius = 8
        textField.layer.shadowOpacity = 1
        textField.layer.shadowRadius = 4
        textField.layer.shadowOffset = CGSize(width: 3, height: 5)
        textField.layer.shadowColor = Palette.shadow.cgColor

        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: textField.bounds.height))
        let searchImageView = UIImageView(frame: CGRect(x: 15, y: 0, width: 22, height: textField.bounds.height))
        searchImageView.image = #imageLiteral(resourceName: "SearchOff")
        searchImageView.contentMode = .scaleAspectFit
        leftView.addSubview(searchImageView)
        
        textField.leftView = leftView
        textField.leftViewMode = UITextField.ViewMode.always
        textField.placeholder = "search".localized()
        textField.text = nil
        textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        textField.isHidden = !sender.isOn
        delegate?.headingSwitchChanged(isOn: sender.isOn)
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        delegate?.textFieldChanged(text: sender.text ?? "")
    }
}

extension HeadingSearchCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.textFieldDone()
        return true
    }
}
