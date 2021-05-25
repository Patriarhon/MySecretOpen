//
//  EmptyStoriesCell.swift
//  My Secret
//
//  Created by Petr on 07.07.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

class EmptyStoriesCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.text = "searchResultIsEmpty".localized()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
