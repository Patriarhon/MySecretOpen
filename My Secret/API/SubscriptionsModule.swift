//
//  SubscriptionsModule.swift
//  My Secret
//
//  Created by Petr on 16.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation
import SwiftyStoreKit

extension API {
    class SubscriptionsModule {
        static func getSubscriptions(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
                
                SwiftyStoreKit.retrieveProductsInfo(["premiumMonth", "premiumQuarter", "premiumForever"]) { result in
                    
        //            for product in result.retrievedProducts {
        //                let priceString = product.localizedPrice!
        //                print("Product: \(product.localizedDescription), price: \(priceString)")
        //                self.prices.append(priceString)
        //            }
                     if let invalidProductId = result.invalidProductIDs.first {
                        print("Invalid product identifier: \(invalidProductId)")
                    } else {
                        print("Error: \(String(describing: result.error))")
                    }
                    
                    if let error = result.error {
                        failure(error)
                    }
                    
                    if result.retrievedProducts.count == 3 {
                        Global.subscriptions = result.retrievedProducts
                        success()
//                        self.subscriptions = result.retrievedProducts
//                        self.setupUI()
                    }
                        
//                        self.contentView.isHidden = true
                    
                    
                }
            }
    }
}
