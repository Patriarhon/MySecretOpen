//
//  BiometricController.swift
//  My Secret
//
//  Created by Petr on 18.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import LocalAuthentication
import SwiftEntryKit

class BiometricController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    let reason = "Вы можете войти с помощью аутентификации"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    private func setupView() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
//        view.addSubview(blurEffectView)
        
        titleLabel.text = "story blocked".localized()
        
        
        let localAuthenticationContext = LAContext()
        //        localAuthenticationContext.localizedFallbackTitle = "Введите ваш пароль"
        //
        var authorizationError: NSError?
        
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authorizationError) {
            
            var bioTypeString = ""
            if localAuthenticationContext.biometryType == .faceID {
                bioTypeString = "Face ID"
            } else if localAuthenticationContext.biometryType == .touchID {
                bioTypeString = "Touch ID"
            }
            
            subtitleLabel.text = "subtitle begin".localized() + bioTypeString + "subtitle end".localized()
            button.setTitle("button begin".localized() + bioTypeString, for: .normal)
            
            authentificate(context: localAuthenticationContext)
            
        } else {
            
            containerView.isHidden = false
            
            guard let error = authorizationError else {
                
                return
            }
            showWarningAlert(text: error.localizedDescription, type: .error)
        }
    }
    
    private func authentificate(context: LAContext) {
        context.evaluatePolicy(.deviceOwnerAuthentication , localizedReason: reason) { success, evaluateError in
            
            if success {
                DispatchQueue.main.async() {
                    SwiftEntryKit.dismiss()
                }
            } else {
                DispatchQueue.main.async {
                    self.containerView.isHidden = false
                }
                
                // Failed to authenticate
                guard let error = evaluateError else {
                    return
                }
                print(error)
            }
        }
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        containerView.isHidden = true
        authentificate(context: LAContext())
    }
    
}

