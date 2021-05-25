//
//  String+localized.swift
//  My Secret
//
//  Created by Petr on 06.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "**\(self)**", comment: "")
    }
}
