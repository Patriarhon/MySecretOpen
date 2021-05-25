//
//  RegistrationController.swift
//  My Secret
//
//  Created by Petr on 28.04.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import FirebaseAuth
import MBProgressHUD

class RegistrationController: UIViewController {
    
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var emailTextField: RoundedShadowTextField!
    @IBOutlet weak var passwordTextField: RoundedShadowTextField!
    @IBOutlet weak var signUpButton: MainButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var privacyTextView: UITextView!
    
    private var keyboardDismissTapGesture: UIGestureRecognizer?
    
    private var isEmailValid = false {
        didSet {
            changeSignInButtonBackground()
        }
    }
    
    private var isPasswordValid = false {
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
        
        let bottomOfSignInButton = signUpButton.convert(signUpButton.bounds, to: self.view).maxY
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
    
    @IBAction func passwordTextChanged(_ sender: RoundedShadowTextField) {
        guard let password = sender.text else {
            isPasswordValid = false
            return
        }
        isPasswordValid = password.count >= 6
    }
    
    @IBAction func didTapSignUpButton(_ sender: MainButton) {
            if isEmailValid && isPasswordValid {
                createUser()
            } else if !isEmailValid {
                showWarningAlert(text: "IncorrectEmailWarning".localized(), type: .warning)
            } else if !isPasswordValid {
                showWarningAlert(text: "IncorrectPasswordWarning".localized(), type: .warning)
            }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Private
    
    private func setupUI() {
        titleLabel.font = UIFont.getFont(font: .sfProTextRegular, size: 24)
        titleLabel.text = "registration".localized()
        logoLabel.text = "logoLabel".localized()
        welcomeLabel.text = "welcomeLabel".localized()

        emailTextField.placeholder = "emailTextFieldPlaceholder".localized()
        emailTextField.font = UIFont.getFont(font: .sfProTextRegular, size: 14)
        passwordTextField.placeholder = "passwordTextFieldPlaceholder".localized()
        passwordTextField.font = UIFont.getFont(font: .sfProTextRegular, size: 14)
        
        signUpButton.setTitle("signUp".localized(), for: .normal)
        
        privacyTextView.font = UIFont.getFont(font: .sfProTextRegular, size: 11)
        
        let beginAttributedString = NSMutableAttributedString(string: "privacyLabelBegin".localized())
        
        let linkAttributes = [
            NSAttributedString.Key.link: NSURL(string: "https://www.apple.com")!,
        NSAttributedString.Key.foregroundColor: UIColor.blue
        ]
        let endAttributedString = NSMutableAttributedString(string: "privacyLabelEnd".localized(), attributes: linkAttributes)
        beginAttributedString.append(endAttributedString)
        privacyTextView.attributedText = beginAttributedString
        privacyTextView.textAlignment = .center
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func changeSignInButtonBackground() {
            signUpButton.backgroundColor = isEmailValid && isPasswordValid ? Palette.darkBlue : Palette.lightGray
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func createUser() {
//        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
//        MBProgressHUD.showAdded(to: view, animated: true)
//        API.AuthorizationModule.createUser(email: email, password: password, success: {
//            MBProgressHUD.hide(for: self.view, animated: true)
//            UIApplication.shared.windows.first?.rootViewController = NavigationHelper.startController
//        }) { (error) in
//            MBProgressHUD.hide(for: self.view, animated: true)
//            self.showWarningAlert(text: error.localizedDescription, type: .error)
//        }
    }
}
