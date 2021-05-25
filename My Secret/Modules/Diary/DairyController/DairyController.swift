//
//  DairyController.swift
//  My Secret
//
//  Created by Petr on 09.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import MBProgressHUD
import CloudKit
import FirebaseAnalytics

class DairyController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emptyDairyView: RoundedShadowView!
    @IBOutlet weak var emptyDairyLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
//    var notes: [NoteModel]?
    var storiesByDate = [String: [Story]]()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
//        getStories()
    }
    
    //MARK: - Actions
    
    @IBAction func writeButtonAction(_ sender: UIButton) {
        let storyController = StoryController.storyboard()
        storyController.delegate = self
        storyController.mode = .new
        present(storyController, animated: true)
    }
    
    @IBAction func settingsButtonAction(_ sender: Any) {
        let settingsController = SettingsController.storyboard()
        navigationController?.pushViewController(settingsController, animated: true)
    }

    
    //MARK: - Private
    
    private func setupView() {
        titleLabel.font = UIFont.getFont(font: .sfProTextSemibold, size: 17)
        titleLabel.text = "my Stories".localized()
        
        emptyDairyLabel.font = UIFont.getFont(font: .sfProTextRegular, size: 14)
        emptyDairyLabel.text = "emptyDairyLabel".localized()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: "NoteCell")
        tableView.register(UINib(nibName: "NoteWithPhotoCell", bundle: nil), forCellReuseIdentifier: "NoteWithPhotoCell")
    }
    
    private func getStories() {
        MBProgressHUD.showAdded(to: view, animated: true)
        API.StoryModule.getNotes(limit: 50, success: { (stories) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.storiesByDate = Dictionary(grouping: stories, by: { DateHelper.dateFormatter.string(from: $0.date) })
            self.tableView.reloadData()
            self.emptyDairyView.isHidden = !self.storiesByDate.isEmpty
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showWarningAlert(text: error.localizedDescription, type: .error)
        }
    }
    
    private func deleteStory(at indexPath: IndexPath) {
        let key = self.storiesByDate.keys.sorted(by: { DateHelper.dateFormatter.date(from: $0)! > DateHelper.dateFormatter.date(from: $1)!})[indexPath.section]
        guard let story = storiesByDate[key]?[indexPath.row] else { return }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        API.StoryModule.delete(story: story, success: { (_) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.getStories()
//            self.storiesByDate[key]?.remove(at: indexPath.row)
//            self.tableView.deleteRows(at: [indexPath], with: .fade)
//            self.tableView.reloadData()
//            self.emptyDairyView.isHidden = !self.storiesByDate.isEmpty
            
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showWarningAlert(text: error.localizedDescription, type: .error)
        }

    }
    
    private func showDeleteAlert(from indexPath: IndexPath) {
        let actionSheetController: UIAlertController = UIAlertController()
                actionSheetController.title = "deleteAlertTitle".localized()
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "cancel".localized(), style: .cancel) { void in
            actionSheetController.dismiss(animated: true, completion: nil)
        }
        actionSheetController.addAction(cancelActionButton)
        
        let deleteActionButton: UIAlertAction = UIAlertAction(title: "delete".localized(), style: .default) { void in
            self.deleteStory(at: indexPath)
//            let key = self.storiesByDate.keys.sorted(by: { DateHelper.dateFormatter.date(from: $0)! > DateHelper.dateFormatter.date(from: $1)!})[indexPath.section]
//            self.storiesByDate[key]?.remove(at: indexPath.row)
//            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        actionSheetController.addAction(deleteActionButton)
        
        present(actionSheetController, animated: true, completion: nil)
    }
}

//MARK: - UITableViewDataSource

extension DairyController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return storiesByDate.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = storiesByDate.keys.sorted(by: { DateHelper.dateFormatter.date(from: $0)! > DateHelper.dateFormatter.date(from: $1)!})[section]
        return  storiesByDate[key]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let key = storiesByDate.keys.sorted(by: { DateHelper.dateFormatter.date(from: $0)! > DateHelper.dateFormatter.date(from: $1)!})[indexPath.section]
        guard let story = storiesByDate[key]?.sorted(by: { $0.date > $1.date })[indexPath.row] else { return UITableViewCell() }
        if story.photos.isEmpty && story.video == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell") as! NoteCell
            cell.setupUI(story: story)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteWithPhotoCell") as! NoteWithPhotoCell
            cell.setupUI(story: story)
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let key = storiesByDate.keys.sorted(by: { DateHelper.dateFormatter.date(from: $0)! > DateHelper.dateFormatter.date(from: $1)!})[section]
        let view = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 34))
        view.setTitle(key)
        return view
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let view = SectionFooterView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
//        return view
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 47
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 20
//    }
}

//MARK: - UITableViewDelegate

extension DairyController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyController = StoryController.storyboard()
        let key = storiesByDate.keys.sorted(by: { DateHelper.dateFormatter.date(from: $0)! > DateHelper.dateFormatter.date(from: $1)!})[indexPath.section]
        guard let story = storiesByDate[key]?.sorted(by: { $0.date > $1.date })[indexPath.row] else { return }
        storyController.story = story
        storyController.delegate = self
        storyController.mode = .view
        present(storyController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showDeleteAlert(from: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}

//MARK: - StoryControllerDelegate

extension DairyController: StoryControllerDelegate {
    func storySaved() {
        getStories()
    }
}

