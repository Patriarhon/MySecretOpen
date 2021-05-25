//
//  SearchController.swift
//  My Secret
//
//  Created by Petr on 09.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import MBProgressHUD
import CloudKit

class SearchController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
//    var notes: [NoteModel]?
    var storiesByDate = [String: [Story]]()
    var searchHeading = ""
    var beginDate: Date?
    var endDate: Date?
    
    var isHeadingSearching = true
    var isDateSearching = true
    
    var isSearched = false
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
//        getStories()
        
//        UIFont.printFonts()
    }
    
    //MARK: - Actions
    
    @IBAction func writeButtonAction(_ sender: UIButton) {
        let storyController = StoryController.storyboard()
        storyController.delegate = self
        storyController.mode = .new
        present(storyController, animated: true)
    }
    
    //MARK: - Private
    
    private func setupView() {
        titleLabel.font = UIFont.getFont(font: .sfProTextSemibold, size: 17)
        titleLabel.text = "history Search".localized()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "HeadingSearchCell", bundle: nil), forCellReuseIdentifier: "HeadingSearchCell")
        tableView.register(UINib(nibName: "DateSearchCell", bundle: nil), forCellReuseIdentifier: "DateSearchCell")
        tableView.register(UINib(nibName: "ButtonCell", bundle: nil), forCellReuseIdentifier: "ButtonCell")
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: "NoteCell")
        tableView.register(UINib(nibName: "NoteWithPhotoCell", bundle: nil), forCellReuseIdentifier: "NoteWithPhotoCell")
        tableView.register(UINib(nibName: "EmptyStoriesCell", bundle: nil), forCellReuseIdentifier: "EmptyStoriesCell")

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func hideKeyboard() {
        tableView.endEditing(true)
    }
    
    private func getFilteredStories() {
        let headingFilter = isHeadingSearching ? searchHeading : ""
        let begin = isDateSearching ? beginDate : nil
        let end = isDateSearching ? endDate : nil
        MBProgressHUD.showAdded(to: view, animated: true)
        API.SearchModule.getFilteredNotes(headingFilter: headingFilter, beginDate: begin, endDate: end, limit: 50, success: { (stories) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.isSearched = true
            self.storiesByDate = Dictionary(grouping: stories, by: { DateHelper.dateFormatter.string(from: $0.date) })
            self.tableView.reloadData()
        }) { (error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showWarningAlert(text: error.localizedDescription, type: .error)
        }
    }
    
    private func deleteStory(at indexPath: IndexPath) {
        let key = self.storiesByDate.keys.sorted(by: { DateHelper.dateFormatter.date(from: $0)! > DateHelper.dateFormatter.date(from: $1)!})[indexPath.section - 3]
        guard let story = storiesByDate[key]?[indexPath.row] else { return }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        API.StoryModule.delete(story: story, success: { (_) in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.getFilteredStories()
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

extension SearchController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if storiesByDate.isEmpty && isSearched {
            return 4
        } else {
            return storiesByDate.keys.count + 3
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 2:
            return 1
        default:
            if storiesByDate.isEmpty && isSearched {
                return 1
            } else {
                let key = storiesByDate.keys.sorted(by: { DateHelper.dateFormatter.date(from: $0)! > DateHelper.dateFormatter.date(from: $1)!})[section - 3]
                return  storiesByDate[key]?.count ?? 0
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeadingSearchCell") as! HeadingSearchCell
//            cell.setupUI(story: story)
            cell.delegate = self
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DateSearchCell") as! DateSearchCell
            //            cell.setupUI(story: story)
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") as! ButtonCell
            //            cell.setupUI(story: story)
            cell.delegate = self
            return cell
        default:
            if storiesByDate.isEmpty && isSearched {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyStoriesCell") as! EmptyStoriesCell
                return cell
            } else {
                let key = storiesByDate.keys.sorted(by: { DateHelper.dateFormatter.date(from: $0)! > DateHelper.dateFormatter.date(from: $1)!})[indexPath.section - 3]
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
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0, 1, 2:
            return nil
        default:
            if storiesByDate.isEmpty && isSearched {
                return nil
            } else {
                let key = storiesByDate.keys.sorted(by: { DateHelper.dateFormatter.date(from: $0)! > DateHelper.dateFormatter.date(from: $1)!})[section - 3]
                let view = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 34))
                view.setTitle(key)
                return view
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1, 2:
            return 0
        default:
            if storiesByDate.isEmpty && isSearched {
                return 0
            } else {
                return 47
            }
            
        }
        
    }
}

//MARK: - UITableViewDelegate

extension SearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section > 2 {
            let storyController = StoryController.storyboard()
            let key = storiesByDate.keys.sorted(by: { DateHelper.dateFormatter.date(from: $0)! > DateHelper.dateFormatter.date(from: $1)!})[indexPath.section - 3]
            guard let story = storiesByDate[key]?.sorted(by: { $0.date > $1.date })[indexPath.row] else { return }
            storyController.story = story
            storyController.delegate = self
            storyController.mode = .view
            present(storyController, animated: true)
        }
        
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

extension SearchController: StoryControllerDelegate {
    func storySaved() {
        getFilteredStories()
    }
}

//MARK: - HeadingSearchCellDelegate

extension SearchController: HeadingSearchCellDelegate {
    func textFieldDone() {
        getFilteredStories()
    }
    
    func headingSwitchChanged(isOn: Bool) {
        isHeadingSearching = isOn
        tableView.reloadData()
    }
    
    func textFieldChanged(text: String) {
        searchHeading = text
        
    }
}

//MARK: - DateSearchCellDelegate

extension SearchController: DateSearchCellDelegate {
    func dateSwitchChanged(isOn: Bool) {
        isDateSearching = isOn
        tableView.reloadData()
    }
    
    func datesSelected(beginDate: Date, endDate: Date) {
        self.beginDate = beginDate
        self.endDate = endDate
    }
}

//MARK: - ButtonCellDelegate

extension SearchController: ButtonCellDelegate {
    func didTapButton() {
        getFilteredStories()
    }
}
