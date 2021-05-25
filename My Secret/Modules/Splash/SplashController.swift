//
//  SplashController.swift
//  My Secret
//
//  Created by Petr on 17.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import LocalAuthentication

class SplashController: UIViewController {
    
    var storiesByDate = [String: [Story]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        getStories()
    }

    private func getStories() {
        API.StoryModule.getNotes(limit: 50, success: { (stories) in
            self.storiesByDate = Dictionary(grouping: stories, by: { DateHelper.dateFormatter.string(from: $0.date) })
            if Global.isOnboardingWatched {
//                if Global.isPasswordDisabled {
                    UIApplication.shared.windows.first?.rootViewController = TabBarController(storiesByDate: self.storiesByDate)
//                } else {
//                    self.authenticationWithTouchID()
//                }
            } else {
                let onboardingController = OnboardingController.storyboard()
                onboardingController.storiesByDate = self.storiesByDate
                UIApplication.shared.windows.first?.rootViewController = onboardingController
            }
        }) { (error) in
            self.showWarningAlert(text: error.localizedDescription, type: .error)
            if Global.isOnboardingWatched {
//                if Global.isPasswordDisabled {
                    UIApplication.shared.windows.first?.rootViewController = TabBarController(storiesByDate: self.storiesByDate)
//                } else {
//                    self.authenticationWithTouchID()
//                }
                
            } else {
                let onboardingController = OnboardingController.storyboard()
                onboardingController.storiesByDate = [String: [Story]]()
                UIApplication.shared.windows.first?.rootViewController = onboardingController
            }
        }
    }
    
    private func authenticationWithTouchID() {
            let localAuthenticationContext = LAContext()
    //        localAuthenticationContext.localizedFallbackTitle = "Введите ваш пароль"
    //
            var authorizationError: NSError?
            let reason = "Вы можете войти с помощью аутентификации"

            if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authorizationError) {
                
                localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
                    
                    if success {
                        
                        DispatchQueue.main.async() {
    //                        let alert = UIAlertController(title: "Success", message: "Authenticated succesfully!", preferredStyle: UIAlertController.Style.alert)
    //                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    //                        self.present(alert, animated: true, completion: nil)
//                            Global.isAuthorized = true
//                            Global.showRootController()
                            UIApplication.shared.windows.first?.rootViewController = TabBarController(storiesByDate: self.storiesByDate)
                        }
                        
                    } else {
                        // Failed to authenticate
                        guard let error = evaluateError else {
                            return
                        }
                        print(error)
                    
                    }
                }
            } else {

                guard let error = authorizationError else {
                    return
                }
                print(error)
            }
        }
}
