//
//  SettingsController.swift
//  My Secret
//
//  Created by Petr on 09.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import MBProgressHUD
import MessageUI
import StoreKit

class SettingsController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        titleLabel.text = "Settings".localized()
        
        tableView.register(UINib(nibName: "SettingCell", bundle: nil), forCellReuseIdentifier: "SettingCell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["mysecretapp2@gmail.com"])
            
            present(mail, animated: true)
        } else {
            showWarningAlert(text: "Unable to open mail".localized(), type: .error)
        }
    }
    
    private func showSubscriptions() {
        let subscriptionsController = SubscriptionsController.storyboard()
        present(subscriptionsController, animated: true)
    }
    
    private func rateApp() {
        let appId = "id1510420527"
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()

        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + appId) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                Global.isRatePresented = true

            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    private func showDeleteAllAlert() {
        let alertController = UIAlertController(title: "Are you sure you want to delete all stories?".localized(), message: "It will be impossible to restore them".localized(), preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Delete".localized(), style: .destructive) { (action) in
            self.deleteAll()
        }
        alertController.addAction(yesAction)
      
        let noAction = UIAlertAction(title: "Cancel".localized(), style: .default)
        alertController.addAction(noAction)
        
        self.present(alertController, animated: true)
    }
    
    private func deleteAll() {
        MBProgressHUD.showAdded(to: view, animated: true)
        API.StoryModule.deleteAllStories(success: { (recordZoneID) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showWarningAlert(text: "All Stories deleted".localized(), type: .ok)
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showWarningAlert(text: error.localizedDescription, type: .error)
        }
    }
    
    private func showOnboarding() {
        let onboardingController = OnboardingController.storyboard()
        present(onboardingController, animated: true)
    }
    
    private func showText(type: TextType) {
        let textController = TextController.storyboard()
        textController.type = type
        present(textController, animated: true)
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension SettingsController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return Global.isPremium ? 0 : 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as! SettingCell
        var type: SettingCellType
        switch indexPath.section {
        case 0:
            type = .premium
        case 1:
            type = .password
        case 2:
            type = .rate
        case 3:
            type = .aboutApp
        case 4:
            type = .support
        case 5:
            type = .terms
        case 6:
            type = .privacy
        case 7:
            type = .delete
        default:
            type = .aboutApp
        }
        cell.setupUI(type: type)
        return cell
    }
}

extension SettingsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            showSubscriptions()
        case 2:
            rateApp()
        case 3:
            showOnboarding()
        case 4:
            sendEmail()
        case 5:
            showText(type: .terms)
        case 6:
            showText(type: .privacy)
        case 7:
            showDeleteAllAlert()
        default:
            break
        }
    }
}

extension SettingsController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

