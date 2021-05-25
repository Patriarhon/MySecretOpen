//
//  BiometricHelper.swift
//  My Secret
//
//  Created by Petr on 07.09.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation
import LocalAuthentication
import SwiftEntryKit

class BiometricHelper {
    static func bioAuthentificate() {
        let localAuthenticationContext = LAContext()
        //        localAuthenticationContext.localizedFallbackTitle = "Введите ваш пароль"
        //
        var authorizationError: NSError?
        let reason = "Вы можете войти с помощью аутентификации"
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authorizationError) {
            
            showBiometricController()
        } else {
            
            guard let error = authorizationError else {
                return
            }
            print(error)
        }
    }
    
    private static func showBiometricController() {
    //        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
    //        let blurEffectView = UIVisualEffectView(effect: blurEffect)
    //        blurEffectView.frame = UIScreen.main.bounds
    //        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            SwiftEntryKit.display(entry: BiometricController.storyboard(), using: setupPopupAttributes())
        }
    
    private static func setupPopupAttributes() -> EKAttributes {
            var attributes = EKAttributes.default
            attributes.displayDuration = .infinity
            attributes.shadow = .none//.active(with: .init(color: .black, opacity: 0.14, radius: 11, offset: CGSize(width: 3, height: 5)))
            
            attributes.positionConstraints = .init(verticalOffset: 0, size: .screen, maxSize: .screen)
            attributes.positionConstraints.safeArea = .overridden
    //        attributes.screenBackground = .color(color: EKColor(Palette.black.withAlphaComponent(0.55)))
            
            
    //        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
            //            attributes.positionConstraints.verticalOffset = 8
            attributes.entryBackground = .color(color: .clear)
            attributes.roundCorners = .none
            
            attributes.screenInteraction = .absorbTouches
            attributes.entryInteraction = .absorbTouches
            
            return attributes
        }
}
