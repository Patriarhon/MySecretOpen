//
//  SettingCell.swift
//  My Secret
//
//  Created by Petr on 09.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

enum SettingCellType {
    case premium
    case password
    case rate
    case aboutApp
    case support
    case terms
    case privacy
    case delete
}

class SettingCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.backgroundColor = UIColor.clear
            containerView.layer.shadowOpacity = 1
            containerView.layer.shadowRadius = 4
            containerView.layer.shadowColor = Palette.shadow.cgColor
            containerView.layer.shadowOffset = CGSize(width: 3, height: 5)
        }
    }
    
    @IBOutlet weak var clippingView: UIView! {
        didSet {
            clippingView.layer.cornerRadius = 8
            clippingView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var openImageView: UIImageView!
    @IBOutlet weak var passwordSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: true)
        
        UIView.animate(withDuration: 0.2) {
            self.clippingView.backgroundColor = highlighted ? Palette.lightGray : Palette.white
        }
        
    }
    
    func setupUI(type: SettingCellType) {
        titleLabel.textColor = Palette.gray
        openImageView.isHidden = false
        passwordSwitch.isHidden = true
        
        switch type {
        case .premium:
            titleLabel.text = "premium".localized()
            typeImageView.image = #imageLiteral(resourceName: "premium")
        case .password:
            titleLabel.text = "password Touch ID Face ID".localized()
            typeImageView.image = #imageLiteral(resourceName: "password")
            openImageView.isHidden = true
            passwordSwitch.isHidden = false
            passwordSwitch.isOn = !Global.isPasswordDisabled
        case .rate:
            titleLabel.text = "rate in App Store".localized()
            typeImageView.image = #imageLiteral(resourceName: "rate")
        case .aboutApp:
            titleLabel.text = "about App".localized()
            typeImageView.image = #imageLiteral(resourceName: "info")
        case .support:
            titleLabel.text = "support".localized()
            typeImageView.image = #imageLiteral(resourceName: "support")
        case .delete:
            titleLabel.text = "remove all records".localized()
            titleLabel.textColor = Palette.red
            typeImageView.image = #imageLiteral(resourceName: "delete")
        case .terms:
            titleLabel.text = "terms of use".localized()
            typeImageView.image = #imageLiteral(resourceName: "terms")
        case .privacy:
            titleLabel.text = "privacy policy".localized()
            typeImageView.image = #imageLiteral(resourceName: "privacy")
        }
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        Global.isPasswordDisabled = !sender.isOn
    }
}
