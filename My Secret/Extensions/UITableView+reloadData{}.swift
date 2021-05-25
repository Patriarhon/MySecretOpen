//
//  UITableView+reloadData{}.swift
//  My Secret
//
//  Created by Petr on 10.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

extension UITableView {
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}
