//
//  AppDelegate.swift
//  My Secret
//
//  Created by Petr on 27.04.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestoreSwift
import SwiftyStoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()

        if #available(iOS 13, *) {
        } else {
            startWindow()
        }
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    
                case .failed, .purchasing, .deferred:
                    break // do nothing
                
                @unknown default:
                    break
                }
            }
        }
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                
                let productId = "premiumForever"
                // Verify the purchase of Consumable or NonConsumable
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let receiptItem):
                    print("\(productId) is purchased: \(receiptItem)")
                    Global.isPremium = true
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                    
                    let productIds = Set([ "premiumMonth",
                                           "premiumQuarter",
                                           "premiumHalfYear",
                                           "premiumForever"])
                    let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                    switch purchaseResult {
                    case .purchased(let expiryDate, let items):
                        print("\(productIds) are valid until \(expiryDate)\n\(items)\n")
                        Global.isPremium = true
                    case .expired(let expiryDate, let items):
                        print("\(productIds) are expired since \(expiryDate)\n\(items)\n")
                        Global.isPremium = false
                    case .notPurchased:
                        print("The user has never purchased \(productIds)")
                        Global.isPremium = false
                    }
                }
                
                if Global.isPremium == false {
                    API.SubscriptionsModule.getSubscriptions(success: {
                        
                    }) { (error) in
                        print(error)
                    }
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
        
        if !Global.isPasswordDisabled {
            BiometricHelper.bioAuthentificate()
        }
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if !Global.isPasswordDisabled {
            BiometricHelper.bioAuthentificate()
        }
    }
    
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        if !Global.isPasswordDisabled {
//            BiometricHelper.bioAuthentificate()
//        }
//    }
    
//    func applicationWillResignActive(_ application: UIApplication) {
//        if !Global.isPasswordDisabled {
//            BiometricHelper.bioAuthentificate()
//        }
//    }
    

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    private func startWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.black
        window?.makeKeyAndVisible()
    
        window?.rootViewController = SplashController.storyboard()//TabBarController()
    }

}

