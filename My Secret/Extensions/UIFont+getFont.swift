//
//  UIFont+getFont.swift
//  My Secret
//
//  Created by Petr on 05.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

extension UIFont {
    enum Font: String {
        case monAmourOneMedium = "MonAmourOne-Medium"
        case adanascript = "Adanascript"
        case futuraPTBook = "FuturaPT-Book"
        case futuraPTMedium = "FuturaPT-Medium"
        case robotoRegular = "Roboto-Regular"
        case robotoMedium = "Roboto-Medium"
        case cothicA1Regular = "GothicA1-Regular"
        case cothicA1Medium = "GothicA1-Medium"
        case pattayaRegular = "Pattaya-Regular"
        case poiretOneRegular = "PoiretOne-Regular"
        case sfProTextLight = "SFProText-Light"
        case sfProTextRegular = "SFProText-Regular"
        case sfProTextMedium = "SFProText-Medium"
        case sfProTextSemibold = "SFProText-Semibold"
        case sintonyBold = "Sintony-Bold"
        case sintonyRegular = "Sintony"
        case sfUIDisplayLight = "SFUIDisplay-Light"
        case sfCompactTextRegular = "SFCompactText-Regular"
        case allegrettoScriptTwo = "AllegrettoScriptTwo"
        case italyB = "ItalyB"
        case tickerTape = "TickerTape"
    }
    
    class func getFont(font: Font = .sfProTextRegular, size: CGFloat = 14) -> UIFont {
        return UIFont(name: font.rawValue, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    class func printFonts() {
        UIFont.familyNames.forEach({
            print("\n--- ", $0, " ---")
            print(UIFont.fontNames(forFamilyName: $0))
        })
    }
}
