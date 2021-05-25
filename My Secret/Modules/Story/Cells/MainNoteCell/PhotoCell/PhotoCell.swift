//
//  PhotoCell.swift
//  My Secret
//
//  Created by Petr on 09.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import Kingfisher
import CloudKit

class PhotoCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var videoPlayImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.kf.cancelDownloadTask()
    }
    
    func setupUI(photo: PhotoModel) {
        videoPlayImageView.isHidden = true
        if let photoReference = photo.cloudReference {
            let provider = ImageProvider(photoID: photoReference.recordID)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: provider)
        } else if let image = photo.image {
            imageView.image = image
        }
    }
    
    func setupUI(video: VideoModel) {
        videoPlayImageView.isHidden = false
        if let videoReference = video.cloudReference {
            let provider = VideoProvider(videoID: videoReference.recordID)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: provider)
        } //else if let image = video.url {
//            imageView.image = image
//        }
    }
}
