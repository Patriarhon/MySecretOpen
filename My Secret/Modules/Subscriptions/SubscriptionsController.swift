//
//  SubscriptionsController.swift
//  My Secret
//
//  Created by Petr on 03.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyStoreKit
import StoreKit

class SubscriptionsController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLable: UILabel!
    
    @IBOutlet var subscriptionContainerViews: [UIView]!
    @IBOutlet var subscriptionClippingViews: [UIView]!
    
    @IBOutlet weak var photoLabel: UILabel!
    @IBOutlet weak var videoLabel: UILabel!
    @IBOutlet weak var audioLabel: UILabel!
    
    @IBOutlet weak var buyButton: MainButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupUI()
//        getSubscriptions()
    }
    
    private func setupView() {
        contentView.isHidden = true
        
        imageView.image = UIImage(named: "premiumImage".localized())
        titleLabel.text = "premium".localized()
        subtitleLable.text = "rates".localized()
        subtitleLable.font = UIFont.getFont(font: .robotoRegular, size: 16)
        photoLabel.font = UIFont.getFont(font: .robotoRegular, size: 16)
        videoLabel.font = UIFont.getFont(font: .robotoRegular, size: 16)
        audioLabel.font = UIFont.getFont(font: .robotoRegular, size: 16)
        photoLabel.text = "photoLabel".localized()
        videoLabel.text = "videoLabel".localized()
        audioLabel.text = "audioLabel".localized()
        
        buyButton.setTitle("premiumAccess".localized(), for: .normal)
        
        let restoreAttributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: Palette.lightBlue, .foregroundColor: Palette.lightBlue]
        let attributedRestore = NSAttributedString(string: "restore subscription".localized(), attributes: restoreAttributes)
        restoreButton.setAttributedTitle(attributedRestore, for: .normal)
        let termsAttributes: [NSAttributedString.Key: Any] = [.underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: Palette.lightBlue, .foregroundColor: Palette.lightBlue]
        let attributedTerms = NSAttributedString(string: "terms of use".localized(), attributes: termsAttributes)
        termsButton.setAttributedTitle(attributedTerms, for: .normal)
        
        for containerView in subscriptionContainerViews.enumerated() {
            containerView.element.backgroundColor = UIColor.clear
            containerView.element.layer.shadowOpacity = 1
            containerView.element.layer.shadowRadius = 4
            containerView.element.layer.shadowColor = Palette.shadow.cgColor
            containerView.element.layer.shadowOffset = CGSize(width: 3, height: 5)
            
            let clippingView = subscriptionClippingViews[containerView.offset]
            clippingView.layer.cornerRadius = 11
            clippingView.layer.masksToBounds = true
//            if containerView.offset == 1 {
//                clippingView.layer.borderWidth = 1
//                clippingView.layer.borderColor = Palette.orange.cgColor
//            }
        }
    }
    
    private func setupUI() {
        guard let subscriptions = Global.subscriptions else {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            API.SubscriptionsModule.getSubscriptions(success: {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.setupUI()
            }) { (error) in
                MBProgressHUD.hide(for: self.view, animated: true)
                self.showWarningAlert(text: error.localizedDescription, type: .error)
            }
            return
        }
        contentView.isHidden = false
//        for i in 0 ... 2 {
//            var subscription: SKProduct!
//            var begin = ""
//            switch i {
//            case 0:
//                subscription = subscriptions.first(where: { $0.productIdentifier == "premiumMonth" })
//                begin = "subscription for 1 month".localized()
//            case 1:
//                subscription = subscriptions.first(where: { $0.productIdentifier == "premiumQuarter" })
//                begin = "subscription for 3 months".localized()
//                let monthlyPrice = (Double(truncating: subscription.price) / 3 * 100).rounded() / 100
//                let currency = subscription.priceLocale.currencyCode ?? ""
//                let string = "(" + "price for month".localized() + " " + String(monthlyPrice) + " " + currency + ")"
//                quarterMonthlyPriceLabel.text = string
//            case 2:
            if let subscription = subscriptions.first(where: { $0.productIdentifier == "premiumForever" }) {
                subtitleLable.text = "The cost - ".localized() + (subscription.localizedPrice ?? "")
            } else {
                subtitleLable.text = ""
            }
            
//                let monthlyPrice = (Double(truncating: subscription.price) / 6 * 100).rounded() / 100
//                let currency = subscription.priceLocale.currencyCode ?? ""
//                let string = "(" + "price for month".localized() + " " + String(monthlyPrice) + " " + currency + ")"
//                halfYearMonthlyPriceLabel.text = string
//            default:
//                break
//            }
//
//            var fontSize: CGFloat = 16
//            if i == 2 {
//                fontSize = 18
//            }
//
//            let attrText = NSMutableAttributedString(string: begin, attributes: [NSAttributedString.Key.font: UIFont.getFont(font: .sfProTextRegular, size: fontSize)])
//            if let localizedPrice = subscription?.localizedPrice {
//                let attrPrice = NSAttributedString(string: localizedPrice, attributes: [NSAttributedString.Key.font: UIFont.getFont(font: .sfProTextSemibold, size: fontSize)])
//                attrText.append(attrPrice)
//            }
//
//            subscriptionTitleLabels[i].attributedText = attrText
            
            
            
            
//            priceLabels[i].text = subscription?.localizedPrice
//        }
    }
    
    private func restoreSubscription() {
        MBProgressHUD.showAdded(to: view, animated: true)
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                self.showWarningAlert(text: "restoreError", type: .error)
            }
            else if results.restoredPurchases.count > 0 {
                for purchase in results.restoredPurchases {
                    // fetch content from your server, then:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }
                print("Restore Success: \(results.restoredPurchases)")
                self.showWarningAlert(text: "restoreSuccess".localized(), title: "", type: .ok, action: nil)
                Global.isPremium = true
                self.dismiss(animated: true)
            }
            else {
                self.showWarningAlert(text: "nothingRestore".localized(), type: .warning)
                print("Nothing to Restore")
            }
        }
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buyButtonAction(_ sender: UIButton) {
        var productId = "premiumForever"
//        for button in buyButtons.enumerated() {
//            if sender == button.element {
//                switch button.offset {
//                case 0:
//                    productId = "premiumMonth"
//                case 1:
//                    productId = "premiumQuarter"
//                case 2:
//                    productId = "premiumForever"
//                default:
//                    break
//                }
//            }
//        }

        MBProgressHUD.showAdded(to: view, animated: true)
        SwiftyStoreKit.purchaseProduct(productId, atomically: true) { result in

            MBProgressHUD.hide(for: self.view, animated: true)

            if case .success(let purchase) = result {
                // Deliver content from server, then:
                
                Global.isPremium = true
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }

//                let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "f9948203b76a4429af74cb78c3efa8f9")
//                SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
//
//                    if case .success(let receipt) = result {
//                        let purchaseResult = SwiftyStoreKit.verifySubscription(
//                            ofType: .autoRenewable,
//                            productId: productId,
//                            inReceipt: receipt)
//
//                        switch purchaseResult {
//                        case .purchased(let expiryDate, let receiptItems):
//                            print("Product is valid until \(expiryDate)")
//                            Global.isPremium = true
//                        case .expired(let expiryDate, let receiptItems):
//                            print("Product is expired since \(expiryDate)")
//                            Global.isPremium = false
//                        case .notPurchased:
//                            print("This product has never been purchased")
//                            Global.isPremium = false
//                        }
//
//                    } else {
//                        Global.isPremium = true
//                    }
//
//                    self.dismiss(animated: true)
//                }
                
                self.dismiss(animated: true)
            } else {
                self.showWarningAlert(text: "error when purchase subscription".localized(), type: .error)
            }
        }
    }
    
    @IBAction func restoreButtonAction(_ sender: Any) {
        restoreSubscription()
    }
    
    @IBAction func termsButtonAction(_ sender: Any) {
        let textController = TextController.storyboard()
        textController.type = .terms
        present(textController, animated: true)
    }
}
