//
//  NoteWithPhotoCell.swift
//  My Secret
//
//  Created by Petr on 09.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import Kingfisher

class NoteWithPhotoCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.backgroundColor = UIColor.clear
            containerView.layer.shadowOpacity = 1
            containerView.layer.shadowRadius = 4
            containerView.layer.shadowColor = Palette.shadow.cgColor
            containerView.layer.shadowOffset = CGSize(width: 3, height: 5)
        }
    }
    
    @IBOutlet weak var clippingView: UIView! {
        didSet {
            clippingView.layer.cornerRadius = 8
            clippingView.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var microphoneImageView: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headingLabel.font = UIFont.getFont(font: .sfProTextMedium, size: 14)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: true)
        
        UIView.animate(withDuration: 0.2) {
            self.clippingView.backgroundColor = highlighted ? Palette.lightGray : Palette.white
        }
        
    }
    
    func setupUI(story: Story) {
        headingLabel.textColor = story.headingColor
        headingLabel.font = StringType.heading.storyFonts[story.headingFontNumber].withSize(14)
        headingLabel.text = story.heading
        if let photoReference = story.photos.first?.cloudReference {
            let provider = ImageProvider(photoID: photoReference.recordID)
            photoImageView.kf.indicatorType = .activity
            photoImageView.kf.setImage(with: provider)
        } else if let image = story.photos.first?.image {
            photoImageView.image = image
        } else if let videoReference = story.video?.cloudReference {
            let provider = VideoProvider(videoID: videoReference.recordID)
            photoImageView.kf.indicatorType = .activity
            photoImageView.kf.setImage(with: provider)
        }
        
        microphoneImageView.isHidden = story.audio == nil
        videoImageView.isHidden = story.video == nil
    }
    
}
