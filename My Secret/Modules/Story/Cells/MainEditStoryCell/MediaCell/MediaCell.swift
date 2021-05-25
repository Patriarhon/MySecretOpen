//
//  MediaCell.swift
//  My Secret
//
//  Created by Petr on 25.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import Kingfisher
import AVKit

enum MediaCellMode {
    case photo
    case video
}

protocol MediaCellDelegate: class {
    func deletePhoto(number: Int)
    func deleteVideo()
}

class MediaCell: UICollectionViewCell {
    
    var mode = MediaCellMode.photo

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var videoPlayImageView: UIImageView!
    
    weak var delegate: MediaCellDelegate?
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) {
                if self.isHighlighted {
                    self.selectedView.backgroundColor? = Palette.lightGray.withAlphaComponent(0.6)
                } else {
                    self.selectedView.backgroundColor? = UIColor.clear
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        if mode == .photo {
            delegate?.deletePhoto(number: tag)
        } else {
            delegate?.deleteVideo()
        }
        
    }
    
    func setupUI(mode: MediaCellMode, photo: PhotoModel? = nil, video: VideoModel? = nil) {
        
        self.mode = mode
        
        videoPlayImageView.isHidden = true
        
        if let photo = photo {
            closeButton.isHidden = false
            if let image = photo.image {
                imageView.image = image
            } else if let recordID = photo.cloudReference?.recordID {
                imageView.kf.indicatorType = .activity
                let imageProvider = ImageProvider(photoID: recordID)
                imageView.kf.setImage(with: imageProvider)
            }
            
        } else if let video = video {
            closeButton.isHidden = false
            
            videoPlayImageView.isHidden = false
            if let videoReference = video.cloudReference {
                let provider = VideoProvider(videoID: videoReference.recordID)
                imageView.kf.indicatorType = .activity
                imageView.kf.setImage(with: provider)
            } else if let videoURL = video.url {
                imageView.image = videoPreviewImage(url: videoURL)
            }
            
            
        } else {
            closeButton.isHidden = true
            switch mode {
            case .photo:
                imageView.image = #imageLiteral(resourceName: "newPhoto")
            case .video:
                imageView.image = #imageLiteral(resourceName: "newVideo")
            }
        }
    }
    
    private func videoPreviewImage(url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        if let cgImage = try? generator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil) {
            let image = UIImage(cgImage: cgImage)
            return image
        } else {
            return nil
        }
    }
}
