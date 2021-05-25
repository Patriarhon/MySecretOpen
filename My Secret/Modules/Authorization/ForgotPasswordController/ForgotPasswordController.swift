//
//  ForgotPasswordController.swift
//  My Secret
//
//  Created by Petr on 09.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import MBProgressHUD

class ForgotPasswordController: UIViewController {

    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var emailTextField: RoundedShadowTextField!
    @IBOutlet weak var resetButton: MainButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    private var keyboardDismissTapGesture: UIGestureRecognizer?
    
    private var isEmailValid = false {
        didSet {
            changeSignInButtonBackground()
        }
    }
    
    private var isPasswordValid = true {
        didSet {
            changeSignInButtonBackground()
        }
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        dismissKeyboard()
    }
    
    //MARK: - Notifications
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue )?.cgRectValue else {return}
        
        if keyboardDismissTapGesture == nil {
            keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            keyboardDismissTapGesture?.cancelsTouchesInView = false
            self.view.addGestureRecognizer(keyboardDismissTapGesture!)
        }
        
        var offset: CGFloat = 0
        
        let bottomOfSignInButton = resetButton.convert(resetButton.bounds, to: self.view).maxY
        let topOfKeyboard = self.view.frame.height - keyboardSize.height
        
        if bottomOfSignInButton + 4 > topOfKeyboard {
            offset = bottomOfSignInButton - topOfKeyboard + 4
        }
        self.view.frame.origin.y = 0 - offset
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if keyboardDismissTapGesture != nil {
            view.removeGestureRecognizer(keyboardDismissTapGesture!)
            keyboardDismissTapGesture = nil
        }
        
        self.view.frame.origin.y = 0
    }
    
    //MARK: - Actions
    
    @IBAction func emailTextChanged(_ sender: RoundedShadowTextField) {
        guard let email = sender.text else {
            isEmailValid = false
            return
        }
        isEmailValid = isValidEmail(email)
    }
    
    @IBAction func didTapSignInButton(_ sender: MainButton) {
            if isEmailValid && isPasswordValid {
//                resetPassword()
            } else {
                showWarningAlert(text: "IncorrectPhoneWarning".localized(), type: .warning)
            }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Private
    
    private func setupUI() {
        titleLabel.font = UIFont.getFont(font: .sfProTextRegular, size: 24)
        titleLabel.text = "passwordReset".localized()
        logoLabel.text = "logoLabel".localized()

        emailTextField.placeholder = "emailTextFieldPlaceholder".localized()
        emailTextField.font = UIFont.getFont(font: .sfProTextRegular, size: 14)
        
        resetButton.setTitle("resetButton".localized(), for: .normal)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func changeSignInButtonBackground() {
            resetButton.backgroundColor = isEmailValid && isPasswordValid ? Palette.darkBlue : Palette.lightGray
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func resetPassword() {
//        guard let email = emailTextField.text else { return }
//        MBProgressHUD.showAdded(to: view, animated: true)
//        API.AuthorizationModule.resetPassword(email: email, success: {
//            MBProgressHUD.hide(for: self.view, animated: true)
//            self.showWarningAlert(text: "passwordReseted".localized(), type: .ok)
//            UIApplication.shared.windows.first?.rootViewController = NavigationHelper.startController
//        }) { (error) in
//            MBProgressHUD.hide(for: self.view, animated: true)
//            self.showWarningAlert(text: error.localizedDescription, type: .error)
//        }
    }
}
