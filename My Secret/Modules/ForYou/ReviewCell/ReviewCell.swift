//
//  ReviewCell.swift
//  My Secret
//
//  Created by Petr on 09.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import Kingfisher

protocol ReviewCellDelegate: class {
    func didTapInstagramButton(tag: Int)
}

class ReviewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var professionLabel: UILabel!
    @IBOutlet weak var instagramLabel: UILabel!
    @IBOutlet weak var mainTextLabel: UILabel!
    
    weak var delegate: ReviewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupUI(review: Review) {
        nameLabel.text = review.name
        professionLabel.text = review.profession
        instagramLabel.text = "@" + review.instagram
        mainTextLabel.text = review.text
        
        if let photoReference = review.photo?.cloudReference {
            let provider = ImageProvider(photoID: photoReference.recordID, isPrivate: false)
            photoImageView.kf.indicatorType = .activity
            photoImageView.kf.setImage(with: provider)
        }
    }
    
    @IBAction func instagramButtonAction(_ sender: Any) {
        delegate?.didTapInstagramButton(tag: tag)
    }
}
