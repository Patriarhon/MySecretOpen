//
//  SignInController.swift
//  My Secret
//
//  Created by Petr on 04.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import PhoneNumberKit
import MBProgressHUD

enum AuthWay: Int {
    case phone
    case email
}

class SignInController: UIViewController {

    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var authWayView: AuthWayView!
    @IBOutlet weak var phoneTextField: PhoneTextField!
    @IBOutlet weak var emailTextField: RoundedShadowTextField!
    @IBOutlet weak var passwordTextField: RoundedShadowTextField!
    @IBOutlet weak var signInButton: MainButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var noAccountLabel: UILabel!
    @IBOutlet weak var privacyTextView: UITextView!
    
    private var authWay = AuthWay.phone {
        didSet {
            setAuthWay()
            changeSignInButtonBackground()
        }
    }
    
    private var keyboardDismissTapGesture: UIGestureRecognizer?
    
    private let phoneNumberKit = PhoneNumberKit()
    
    private var isPhoneValid = false {
        didSet {
            changeSignInButtonBackground()
        }
    }
    
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
        
        let bottomOfSignInButton = signInButton.convert(signInButton.bounds, to: self.view).maxY
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
    
    @IBAction func phoneTextChanged(_ sender: PhoneNumberTextField) {
        guard let phoneNumber = sender.text else {
            isPhoneValid = false
            return
        }
        isPhoneValid = phoneNumberKit.isValidPhoneNumber(phoneNumber)
    }
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
    
    @IBAction func didTapSignInButton(_ sender: MainButton) {
        switch authWay {
        case .phone:
            if isPhoneValid {
                verifyPhone()
            } else {
                showWarningAlert(text: "IncorrectPhoneWarning".localized(), type: .warning)
            }
        case .email:
            if isEmailValid && isPasswordValid {
                signIn()
            } else if !isEmailValid {
                showWarningAlert(text: "IncorrectEmailWarning".localized(), type: .warning)
            } else if !isPasswordValid {
                showWarningAlert(text: "IncorrectPasswordWarning".localized(), type: .warning)
            }
        }
    }
    
    @IBAction func didTapRegistrationButton(_ sender: UIButton) {
        let registrationController = RegistrationController.storyboard(isSmallAvailable: true)
        navigationController?.pushViewController(registrationController, animated: true)
    }
    
    @IBAction func didTapForgotButton(_ sender: UIButton) {
        let forgotPasswordController = ForgotPasswordController.storyboard(isSmallAvailable: true)
        navigationController?.pushViewController(forgotPasswordController, animated: true)
    }
    
    //MARK: - Private
    
    private func setupUI() {
        logoLabel.text = "logoLabel".localized()
        welcomeLabel.text = "welcomeLabel".localized()
        
        authWayView.delegate = self
        
        phoneTextField.withFlag = true
        phoneTextField.withDefaultPickerUI = true
        phoneTextField.withExamplePlaceholder = true
        phoneTextField.withPrefix = true
//        phoneTextField.phoneNumberKit.for
//        phoneTextField.placeholder = "phoneTextFieldPlaceholder".localized()
        phoneTextField.font = UIFont.getFont(font: .sfProTextRegular, size: 14)
        emailTextField.placeholder = "emailTextFieldPlaceholder".localized()
        emailTextField.font = UIFont.getFont(font: .sfProTextRegular, size: 14)
        passwordTextField.placeholder = "passwordTextFieldPlaceholder".localized()
        passwordTextField.font = UIFont.getFont(font: .sfProTextRegular, size: 14)
        
        signInButton.setTitle("signInButton".localized(), for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.getFont(font: .sfProTextRegular, size: 12)
        let attributedTitle = NSAttributedString(string: "forgotPasswordButton".localized(), attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
        forgotPasswordButton.setAttributedTitle(attributedTitle, for: .normal)
        
        registrationButton.setTitle("registrationButton".localized(), for: .normal)
        registrationButton.titleLabel?.font = UIFont.getFont(font: .robotoRegular, size: 14)
        registrationButton.layer.borderWidth = 1
        registrationButton.layer.borderColor = UIColor(named: "DarkBlue")?.cgColor
        registrationButton.layer.cornerRadius = 8
        
        noAccountLabel.font = UIFont.getFont(font: .sfProTextRegular, size: 12)
        noAccountLabel.text = "noAccountLabel".localized()
        
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
        
        setAuthWay()
    }
    
    private func setAuthWay() {
        switch authWay {
        case .phone:
            phoneTextField.isHidden = false
            emailTextField.isHidden = true
            passwordTextField.isHidden = true
            forgotPasswordButton.isHidden = true
            registrationButton.isHidden = true
            noAccountLabel.isHidden = true
            signInButton.setTitle("signInButton".localized() + " / " + "signUp".localized(), for: .normal)
            privacyTextView.isHidden = false
        case.email:
            phoneTextField.isHidden = true
            emailTextField.isHidden = false
            passwordTextField.isHidden = false
            forgotPasswordButton.isHidden = false
            registrationButton.isHidden = false
            noAccountLabel.isHidden = false
            signInButton.setTitle("signInButton".localized(), for: .normal)
            privacyTextView.isHidden = true
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func changeSignInButtonBackground() {
        switch authWay {
        case .phone:
            signInButton.backgroundColor = isPhoneValid ? Palette.darkBlue : Palette.lightGray
        case .email:
            signInButton.backgroundColor = isEmailValid && isPasswordValid ? Palette.darkBlue : Palette.lightGray
        }
    }
    
    private func verifyPhone() {
        if isPhoneValid, let phoneNumber = phoneTextField.text {
            MBProgressHUD.showAdded(to: view, animated: true)
            API.AuthorizationModule.verifyPhone(number: phoneNumber, success: { (verificationID) in
                MBProgressHUD.hide(for: self.view, animated: true)
                let inputCodeController = InputCodeController.storyboard(isSmallAvailable: true)
                inputCodeController.phone = phoneNumber
                self.navigationController?.pushViewController(inputCodeController, animated: true)
//                verificationID
            }) { (error) in
                MBProgressHUD.hide(for: self.view, animated: true)
                self.showWarningAlert(text: error.localizedDescription, type: .error)
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func signIn() {
//        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
//        MBProgressHUD.showAdded(to: view, animated: true)
//        API.AuthorizationModule.signIn(email: email, password: password, success: {
//            MBProgressHUD.hide(for: self.view, animated: true)
//            UIApplication.shared.windows.first?.rootViewController = NavigationHelper.startController
//        }) { (error) in
//            MBProgressHUD.hide(for: self.view, animated: true)
//            self.showWarningAlert(text: error.localizedDescription, type: .error)
//        }
    }
}

//MARK: - AuthWayViewDelegate

extension SignInController: AuthWayViewDelegate {
    func didChange(modeNumber: Int) {
        guard let authWay = AuthWay(rawValue: modeNumber) else { return }
        self.authWay = authWay
    }
}
