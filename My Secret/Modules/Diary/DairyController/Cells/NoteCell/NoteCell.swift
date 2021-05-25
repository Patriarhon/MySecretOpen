//
//  NoteCell.swift
//  My Secret
//
//  Created by Petr on 17.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    
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
    @IBOutlet weak var thoughtsLabel: UILabel!

    @IBOutlet weak var microphoneImageView: UIImageView!
    @IBOutlet weak var videoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headingLabel.font = UIFont.getFont(font: .sfProTextMedium, size: 14)
        thoughtsLabel.font = UIFont.getFont(font: .sfUIDisplayLight, size: 11)
    }
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: true)
//        
//        clippingView.backgroundColor = selected ? Palette.lightGray : Palette.white
//    }
    
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
        
        thoughtsLabel.textColor = story.textColor
        thoughtsLabel.font = StringType.thoughts.storyFonts[story.textFontNumber].withSize(11)
        thoughtsLabel.text = story.text
        
        microphoneImageView.isHidden = story.audio == nil
        videoImageView.isHidden = story.video == nil
    }
    
}
