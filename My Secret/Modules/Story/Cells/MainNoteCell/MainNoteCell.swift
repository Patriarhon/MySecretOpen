//
//  MainNoteCell.swift
//  My Secret
//
//  Created by Petr on 14.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import Kingfisher
import CloudKit
import AVFoundation
import MBProgressHUD

protocol MainNoteCellDelegate: class {
//    func didTapHeading()
//    func didTapCalend()
//    func didTapLocation()
//    func didTapThoughtars()
    func didTapPhoto(photo: PhotoModel, index: Int)
    func didTapVideo()
    func showSubscriptions()
}

class MainNoteCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            // Make it card-like
            containerView.backgroundColor = UIColor.clear
            containerView.layer.shadowOpacity = 1
            containerView.layer.shadowRadius = 11
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
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var thoughtsLabel: UILabel!
    
    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headingLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playButton: RoundedShadownButton!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    weak var delegate: MainNoteCellDelegate?
    
    var story: Story!
    
    var photoRatio: CGFloat = 1
    
    var player: AVAudioPlayer?
    var timer: Timer?
    var isPlaying = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        headingLabel.font = UIFont.getFont(font: .sfProTextMedium, size: 16)
        headingLabel.text = "headingLabel".localized()
        
        dateLabel.font = UIFont.getFont(font: .sfProTextRegular, size: 12)
        let date = Date()
        dateLabel.text = DateHelper.dateFormatter.string(from: date)
        
        locationLabel.font = UIFont.getFont(font: .sfProTextRegular, size: 12)
        locationLabel.text = "locationLabel".localized()
        
        thoughtsLabel.font = UIFont.getFont(font: .sfProTextRegular, size: 14)
        thoughtsLabel.text = "thoughtsLabel".localized()
        
        slider.setThumbImage(#imageLiteral(resourceName: "sliderThumb"), for: .normal)
        slider.setThumbImage(#imageLiteral(resourceName: "sliderThumb"), for: .highlighted)
    }
    
    func setupUI(story: Story) {
        self.story = story
        
        var numberOfPages = story.photos.count
        if story.video != nil {
            numberOfPages += 1
        }
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        
        headingLabel.textColor = story.headingColor
        headingLabel.font = StringType.heading.storyFonts[story.headingFontNumber].withSize(16)
        if let heading = story.heading, !heading.isEmpty {
            headingLabel.text = heading
        } else {
            headingLabel.text = "headingLabel".localized()
        }
        
        locationLabel.textColor = story.placeColor
        locationLabel.font = StringType.place.storyFonts[story.placeFontNumber].withSize(12)
        locationLabel.text = story.place
        if let location = story.place, !location.isEmpty {
            locationView.isHidden = false
        } else {
            locationView.isHidden = true
        }
        
        thoughtsLabel.textColor = story.textColor
        thoughtsLabel.font = StringType.place.storyFonts[story.textFontNumber].withSize(14)
        thoughtsLabel.text = story.text
        if let thoughts = story.text, !thoughts.isEmpty {
            thoughtsLabel.isHidden = false
        } else {
            thoughtsLabel.isHidden = true
        }
        
        dateLabel.text = DateHelper.dateFormatter.string(from: story.date)
        
        if story.photos.isEmpty && story.video == nil {
            collectionHeightConstraint.constant = 0
            headingLabelTopConstraint.constant = 16
            pageControl.isHidden = true
        } else if (story.photos.count == 1 && story.video == nil) || (story.photos.isEmpty && story.video != nil) {
            collectionHeightConstraint.constant = UIScreen.main.bounds.width - 40
            headingLabelTopConstraint.constant = 8
            pageControl.isHidden = true
        } else {
            collectionHeightConstraint.constant = UIScreen.main.bounds.width - 40
            headingLabelTopConstraint.constant = 28
            
            pageControl.isHidden = false
        }
        
        self.contentView.layoutIfNeeded()
        
        setupPlayerView(audioModel: story.audio)
    }
    
    private func setupPlayerView(audioModel: AudioModel?) {
        guard let audioModel = audioModel else {
            playerView.isHidden = true
            return
        }
        
        playerView.isHidden = false
        
        if let url = audioModel.url {
            setupPlayer(url: url)
        } else if let audioID = audioModel.cloudReference?.recordID {
            slider.value = 0.0
            self.elapsedTimeLabel.text = "0:00"
            self.remainingTimeLabel.text = "-:--"
            slider.isUserInteractionEnabled = false
//            self.elapsedTimeLabel.text = self.player.currentTime.secondsToString()
//            self.remainingTimeLabel.text = (self.player.duration - self.player.currentTime).secondsToString()
        }
    }
    
    private func loadAudio(audioID: CKRecord.ID) {
        MBProgressHUD.showAdded(to: self.playerView, animated: true)
        API.StoryModule.getAudioUrl(audioID: audioID, success: { (url) in
            DispatchQueue.main.async {
                self.setupPlayer(url: url)
                self.player?.play()
                self.setPlayButtonState()
                MBProgressHUD.hide(for: self.playerView, animated: true)
            }
        }) { (error) in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.playerView, animated: true)
                print(error.localizedDescription)
            }
        }
    }
    
    private func setupPlayer(url: URL) {
        do {
            slider.isUserInteractionEnabled = true
            self.player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 1.0
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)
               } catch _ {
            }
            player?.delegate = self
            slider.value = 0.0
            slider.maximumValue = Float((player?.duration)!)
            self.elapsedTimeLabel.text = self.player?.currentTime.secondsToString()
            self.remainingTimeLabel.text = (self.player!.duration - self.player!.currentTime).secondsToString()
            timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc private func updateSlider(){
        guard let player = player else { return }
        slider.value = Float(player.currentTime)
        self.elapsedTimeLabel.text = player.currentTime.secondsToString()
        self.remainingTimeLabel.text = (player.duration - player.currentTime).secondsToString()
    }
    
    @IBAction func togglePlay(_ sender: Any) {
        if Global.isPremium {
            if player == nil, let audioID = story.audio?.cloudReference?.recordID {
                loadAudio(audioID: audioID)
            } else {
                if player!.isPlaying {
                    player!.pause()
                    isPlaying = false
                } else {
                    player!.play()
                    isPlaying = true
                }
                
            }
            setPlayButtonState()
        } else {
            delegate?.showSubscriptions()
        }
        
    }
    
        @IBAction func startScrubbing(_ sender: UISlider) {
    //        player.pause()
            guard Global.isPremium else { return }
            timer?.invalidate()
        }
        
        @IBAction func scrubbing(_ sender: UISlider) {
    //        player.currentTime = Double(slider.value)
            guard Global.isPremium else { return }
            timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
            if isPlaying {
                player?.play()
            }
        }
        
        @IBAction func scrubbingValueChanged(_ sender: UISlider) {
            guard Global.isPremium else { return }
            guard let player = player else { return }
            let value = Double(slider.value)
            elapsedTimeLabel.text = value.secondsToString()
            remainingTimeLabel.text = (player.duration - value).secondsToString()
            player.currentTime = value
        }
        
        func setPlayButtonState() {
            guard let player = player else {
                playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
                return
            }
            if player.isPlaying {
                playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            } else {
                playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            }
        }
        
        func setErrorMessage(_ message: String) {
            MBProgressHUD.hide(for: contentView, animated: true)
        }
        
    func stopPlayer() {
        isPlaying = false
        player = nil
        timer?.invalidate()
        timer = nil
        setPlayButtonState()
    }
}

extension MainNoteCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let videoCount = story.video == nil ? 0 : 1
        return story.photos.count + videoCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < story.photos.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            cell.setupUI(photo: story.photos[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            cell.setupUI(video: story.video!)
            return cell
        }
    }
    
}

extension  MainNoteCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if indexPath.row < story.photos.count {
            delegate?.didTapPhoto(photo: story.photos[indexPath.row], index: indexPath.row)
        } else {
            stopPlayer()
            delegate?.didTapVideo()
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
        if let ip = collectionView.indexPathForItem(at: center) {
            self.pageControl.currentPage = ip.row
        }
    }
}

extension MainNoteCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width - 40
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}

extension MainNoteCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        timer?.invalidate()
        isPlaying = false
        setPlayButtonState()
    }
}
