//
//  ForYouController.swift
//  My Secret
//
//  Created by Petr on 09.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import MBProgressHUD
import MessageUI

class ForYouController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var reviews = [Review]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        getReviews()
    }
    
    private func setupView() {
        titleLabel.text = "ForYou".localized()
        
        tableView.register(UINib(nibName: "ReviewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        tableView.dataSource = self
    }
    
    private func getReviews() {
        MBProgressHUD.showAdded(to: view, animated: true)
        API.ForYouModule.getReviews(limit: 40, success: { (reviews) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.reviews = reviews
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showWarningAlert(text: error.localizedDescription, type: .error)
        }
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
    
    @IBAction func mailButtonAction(_ sender: Any) {
        sendEmail()
    }
    
//    @IBAction func settingsButtonAction(_ sender: Any) {
//        let settingsController = SettingsController.storyboard()
//        navigationController?.pushViewController(settingsController, animated: true)
//    }
}

extension ForYouController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell") as! ReviewCell
        cell.delegate = self
        cell.tag = indexPath.row
        cell.setupUI(review: reviews[indexPath.row])
        return cell
    }
}

extension ForYouController: ReviewCellDelegate {
    func didTapInstagramButton(tag: Int) {
        if let appURL = URL(string: "instagram://user?username=\(reviews[tag].instagram)") {
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                // if Instagram app is not installed, open URL inside Safari
                let webURL = URL(string: "https://instagram.com/\(reviews[tag].instagram)")!
                application.open(webURL)
            }
        }
    }
}

extension ForYouController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
