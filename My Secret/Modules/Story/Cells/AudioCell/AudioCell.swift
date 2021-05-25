//
//  AudioCell.swift
//  My Secret
//
//  Created by Petr on 21.06.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import CloudKit
//import SwiftAudio
import MBProgressHUD
import AVFoundation

class AudioCell: UITableViewCell {

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

    @IBOutlet weak var playButton: RoundedShadownButton!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    var player: AVAudioPlayer!
    
    var timer: Timer?
    
    var isPlaying = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
        
        
    func setupUI(audioModel: AudioModel) {
        if let url = audioModel.url {
            setupPlayer(url: url)
        } else if let audioID = audioModel.cloudReference?.recordID {
            MBProgressHUD.showAdded(to: self.clippingView, animated: true)
            API.StoryModule.getAudioUrl(audioID: audioID, success: { (url) in
                DispatchQueue.main.async {
                    self.setupPlayer(url: url)
                    MBProgressHUD.hide(for: self.clippingView, animated: true)
                }
            }) { (error) in
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.clippingView, animated: true)
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func togglePlay(_ sender: Any) {
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
        setPlayButtonState()
    }
    
    @IBAction func startScrubbing(_ sender: UISlider) {
//        player.pause()
        timer?.invalidate()
    }
    
    @IBAction func scrubbing(_ sender: UISlider) {
//        player.currentTime = Double(slider.value)
        timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        if isPlaying {
            player.play()
        }
    }
    
    @IBAction func scrubbingValueChanged(_ sender: UISlider) {
        let value = Double(slider.value)
        elapsedTimeLabel.text = value.secondsToString()
        remainingTimeLabel.text = (player.duration - value).secondsToString()
        player.currentTime = value
    }
    
//    func updateTimeValues() {
//        self.slider.maximumValue = Float(self.player.duration)
//        self.slider.setValue(Float(self.player.currentTime), animated: true)
//        self.elapsedTimeLabel.text = self.player.currentTime.secondsToString()
//        self.remainingTimeLabel.text = (self.player.duration - self.player.currentTime).secondsToString()
//    }
    
    func setPlayButtonState() {
        if player.isPlaying {
            playButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            playButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    
    func setErrorMessage(_ message: String) {
        MBProgressHUD.hide(for: contentView, animated: true)
        
//        self.loadIndicator.stopAnimating()
//        errorLabel.isHidden = false
//        errorLabel.text = message
    }
    
    private func setupPlayer(url: URL) {
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            player.volume = 1.0
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback)  //.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
               } catch _ {
            }
            player.delegate = self
            slider.value = 0.0
            slider.maximumValue = Float((player?.duration)!)
            self.elapsedTimeLabel.text = self.player.currentTime.secondsToString()
            self.remainingTimeLabel.text = (self.player.duration - self.player.currentTime).secondsToString()
            timer = Timer.scheduledTimer(timeInterval: 0.0001, target: self, selector: #selector(self.updateSlider), userInfo: nil, repeats: true)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc private func updateSlider(){

        slider.value = Float(player.currentTime)
        self.elapsedTimeLabel.text = self.player.currentTime.secondsToString()
        self.remainingTimeLabel.text = (self.player.duration - self.player.currentTime).secondsToString()
    }
}

extension AudioCell: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        timer?.invalidate()
        isPlaying = false
        setPlayButtonState()
    }
}
