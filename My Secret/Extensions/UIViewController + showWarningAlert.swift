//
//  UIViewController + showWarningAlert.swift
//  My Secret
//
//  Created by Petr on 06.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import SwiftEntryKit

enum AlertType {
    case ok
    case warning
    case error
    
    var color: UIColor {
        switch self {
        case .ok: return #colorLiteral(red: 0.1803921569, green: 0.8, blue: 0.4431372549, alpha: 1)
        case .warning: return #colorLiteral(red: 0.9529411765, green: 0.6117647059, blue: 0.07058823529, alpha: 1)
        case .error: return #colorLiteral(red: 0.7529411765, green: 0.2235294118, blue: 0.168627451, alpha: 1)
        }
    }
}

extension UIViewController {
    func showWarningAlert(text: String, title: String = "WarningTitle".localized(), type: AlertType, action: (() -> ())? = nil) {
        
        var attributes = EKAttributes.topNote
        
        attributes.entryBackground = .color(color: EKColor(type.color))
        //        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        //        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.minY), height: .intrinsic)
        
        let title = EKProperty.LabelContent(text: title, style: .init(font: UIFont.getFont(font: .sfProTextRegular, size: 14), color: .white))
        let description = EKProperty.LabelContent(text: text, style: .init(font: UIFont.getFont(font: .sfProTextRegular, size: 12), color: .white))
        //        let image = EKProperty.ImageContent(image: #imageLiteral(resourceName: "warningIcon"), size: CGSize(width: 35, height: 35))
        let simpleMessage = EKSimpleMessage(image: nil, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
        
        action?()
    }
}
