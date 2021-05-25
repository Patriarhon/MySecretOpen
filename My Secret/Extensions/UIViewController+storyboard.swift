//
//  UIViewController+storyboardViewController.swift
//  My Secret
//
//  Created by Petr on 28.04.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

extension UIViewController {
    static var topViewController: UIViewController? {
        guard var topController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
            
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }

        return topController
    }
    
    static func storyboard(isSmallAvailable: Bool = false) -> Self {
        let storyboard = UIStoryboard(name: String(describing: Self.self), bundle: nil)
        if UIScreen.main.bounds.height < 736, isSmallAvailable, let vc = storyboard.instantiateViewController(withIdentifier: String(describing: Self.self) + "Small") as? Self {
            return vc
        }
        
        guard let vc = storyboard.instantiateViewController(withIdentifier: String(describing: Self.self)) as? Self else {
            fatalError("Could not instantiate initial storyboard with name: \(Self.self)")
        }
        
        return vc
    }
}
