//
//  Double+SecondsToString().swift
//  My Secret
//
//  Created by Petr on 21.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation

extension Double {
    
    private var formatter: DateComponentsFormatter {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }
    
    func secondsToString() -> String {
        return formatter.string(from: self) ?? ""
    }
    
}
