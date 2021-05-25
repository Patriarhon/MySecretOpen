//
//  IAPHelper.swift
//  My Secret
//
//  Created by Petr on 03.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import StoreKit

class Global {
    static var isPremium: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isPremium")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isPremium")
        }
    }
    
    static var isOnboardingWatched: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isOnboardingWatched")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isOnboardingWatched")
        }
    }
    
    static var isPasswordDisabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isPasswordDisabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isPasswordDisabled")
        }
    }
    
    static var isAuthentificated: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isAuthentificated")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isAuthentificated")
        }
    }
    
    static var isRatePresented: Bool {
        get {
            UserDefaults.standard.bool(forKey: "isRatePresented")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isRatePresented")
        }
    }
    
    static var subscriptions: Set<SKProduct>?
}
