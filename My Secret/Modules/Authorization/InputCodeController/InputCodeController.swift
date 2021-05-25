//
//  InputCodeController.swift
//  My Secret
//
//  Created by Petr on 07.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import MBProgressHUD
import PhoneNumberKit

class InputCodeController: UIViewController {

    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var enterCodeTextField: RoundedShadowTextField!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var sendAgainButton: MainButton!
    @IBOutlet weak var sendAgainLabel: UILabel!
    
    var phone: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        logoLabel.text = "logoLabel".localized()
        sendAgainLabel.text = "sendAgainLabel".localized()
        let phoneNumberKit = PhoneNumberKit()
        do {
            let phoneNumber = try phoneNumberKit.parse(phone)
//            let phoneNumberCustomDefaultRegion = try phoneNumberKit.parse("+44 20 7031 3000", withRegion: "GB", ignoreType: true)
            let formattedNumber = phoneNumberKit.format(phoneNumber, toType: .international)
            numberLabel.text = "numberLabelBegin".localized() + formattedNumber + "numberLabelEnd".localized()
        }
        catch {
            numberLabel.text = ""
            print("Generic parser error")
        }
        
//        numberLabel.text
        
        enterCodeTextField.placeholder = "enterCodeTextFieldPlaceholder".localized()
        enterCodeTextField.font = UIFont.getFont(font: .sfProTextRegular, size: 14)
        
        sendAgainButton.setTitle("sendAgainButton".localized(), for: .normal)
    }
    
    private func send(code: String) {
//        MBProgressHUD.showAdded(to: view, animated: true)
//        API.AuthorizationModule.send(code: code, success: {
//            MBProgressHUD.hide(for: self.view, animated: true)
//            print("User signedIn")
//            UIApplication.shared.windows.first?.rootViewController = NavigationHelper.startController
//        }) { (error) in
//            MBProgressHUD.hide(for: self.view, animated: true)
//            self.showWarningAlert(text: error.localizedDescription, type: .error)
//        }
    }
    
    @IBAction func codeTextFieldChanged(_ sender: RoundedShadowTextField) {
        if let code = sender.text, code.count == 6 {
            send(code: code)
        }
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapResendButton(_ sender: MainButton) {
        MBProgressHUD.showAdded(to: view, animated: true)
        API.AuthorizationModule.verifyPhone(number: phone, success: { (_) in
            MBProgressHUD.hide(for: self.view, animated: true)
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showWarningAlert(text: error.localizedDescription, type: .error)
        }
    }
}
