//
//  MainEditStoryCell.swift
//  My Secret
//
//  Created by Petr on 25.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import AVFoundation
import MBProgressHUD
import CloudKit

protocol MainEditStoryCellDelegate: class {
    func didTapHeading()
    func didTapCalendar()
    func didTapLocation()
    func didTapThoughts()
    func didTapAddPhoto()
    func didTapAddVideo()
    func didTapPhoto(number: Int)
    func deletePhoto(number: Int)
    func deleteVideo()
    func didTapDeleteAudioButton()
    func showSubscriptions()
}

class MainEditStoryCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var thoughtsLabel: UILabel!
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playButton: RoundedShadownButton!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
//    var photoImages = [UIImage]()
    var story: Story!
    
    weak var delegate: MainEditStoryCellDelegate?
    
    var player: AVAudioPlayer?
    var timer: Timer?
    var isPlaying = false
    
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

    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.dataSource = self
        collectionView.delegate = self
//        collectionView.collectionViewLayout = self
        collectionView.register(UINib(nibName: "MediaCell", bundle: nil), forCellWithReuseIdentifier: "MediaCell")
        
        headingLabel.font = UIFont.getFont(font: .sfProTextSemibold, size: 16)
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
        
        headingLabel.textColor = story.headingColor
        headingLabel.font = StringType.heading.storyFonts[story.headingFontNumber].withSize(16)
        
        if let heading = story.heading, !heading.isEmpty {
            headingLabel.text = story.heading
        } else {
            headingLabel.text = "headingLabel".localized()
        }
        
        locationLabel.textColor = story.placeColor
        locationLabel.font = StringType.place.storyFonts[story.placeFontNumber].withSize(12)
        if let location = story.place, !location.isEmpty {
            locationLabel.text = story.place
        } else {
            locationLabel.text = "locationLabel".localized()
        }
        
        thoughtsLabel.textColor = story.textColor
        thoughtsLabel.font = StringType.place.storyFonts[story.textFontNumber].withSize(14)
        if let thoughts = story.text, !thoughts.isEmpty {
            thoughtsLabel.text = story.text
        } else {
            thoughtsLabel.text = "thoughtsLabel".localized()
        }
        
        dateLabel.text = DateHelper.dateFormatter.string(from: story.date)
        
//        self.photoImages = photoImages ?? [UIImage]()
        collectionView.reloadData()
        
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
        }
    }
    
    private func loadAudio(audioID: CKRecord.ID) {
        MBProgressHUD.showAdded(to: self.playerView, animated: true)
        API.StoryModule.getAudioUrl(audioID: audioID, success: { (url) in
            DispatchQueue.main.async {
                self.setupPlayer(url: url)
                self.player?.play()
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
    
    @IBAction func headingButtonAction(_ sender: Any) {
        delegate?.didTapHeading()
    }
    
    @IBAction func calendarButtonAction(_ sender: UIButton) {
        delegate?.didTapCalendar()
    }
    
    @IBAction func locationButtonAction(_ sender: UIButton) {
        delegate?.didTapLocation()
    }
    
    @IBAction func thoughtsButtonAction(_ sender: UIButton) {
        delegate?.didTapThoughts()
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
        
    @IBAction func deleteButtonAction(_ sender: Any) {
        delegate?.didTapDeleteAudioButton()
    }
    
    func setPlayButtonState() {
        guard let player = player else { return }
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

extension MainEditStoryCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as! MediaCell
        if indexPath.item != 5 {
                cell.tag = indexPath.row
                cell.delegate = self
            if indexPath.row < story.photos.count {
                cell.setupUI(mode: .photo, photo: story.photos[indexPath.row])
            } else {
                cell.setupUI(mode: .photo, photo: nil)
            }
            
        } else {
            cell.delegate = self
            cell.setupUI(mode: .video, video: story.video)
        }
        return cell
    }
}

extension MainEditStoryCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if indexPath.item == 5 {
            delegate?.didTapAddVideo()
            stopPlayer()
        } else {
            if indexPath.row < story.photos.count {
                delegate?.didTapPhoto(number: indexPath.row)
            } else {
                delegate?.didTapAddPhoto()
            }
            
        }
    }
}

extension MainEditStoryCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow: CGFloat = 3
        let noOfCellsInColumn: CGFloat = 2
        let horizontalInset: CGFloat = 20
        let topInset: CGFloat = 16
        let bottomInset: CGFloat = 22
        let lineSpacing: CGFloat = 8
        let columnSpacing: CGFloat = 8
        
        let height = (collectionView.frame.size.height - topInset - bottomInset - (noOfCellsInColumn - 1) * lineSpacing) / 2
        let width = (collectionView.frame.size.width - horizontalInset * 2 - (noOfCellsInRow - 1) * columnSpacing) / 3
        
        return CGSize(width: width, height: height)
    }
}

extension MainEditStoryCell: MediaCellDelegate {
    func deleteVideo() {
        delegate?.deleteVideo()
    }
    
    func deletePhoto(number: Int) {
        delegate?.deletePhoto(number: number)
    }
}

extension MainEditStoryCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        timer?.invalidate()
        isPlaying = false
        setPlayButtonState()
    }
}

