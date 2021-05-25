//
//  FullPhotoController.swift
//  My Secret
//
//  Created by Petr on 25.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit
import CloudKit
import Kingfisher

enum FullPhotoControllerMode {
    case edit
    case view
}

protocol FullPhotoControllerDelegate: class {
    func deletePhoto(number: Int)
}

class FullPhotoController: UIViewController {
//    var photoID: CKRecord.ID?
    var photo: PhotoModel!
    var numberOfPhoto: Int?
    
    var mode = FullPhotoControllerMode.view

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var delegate: FullPhotoControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    @IBAction func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        self.dismiss(animated: true) {
            guard let numberOfPhoto = self.numberOfPhoto else { return }
            self.delegate?.deletePhoto(number: numberOfPhoto)
        }
    }
    
    @IBAction func didSwipe(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true)
//        coordinator?.dismissFullPhoto()
    }
    
    private func setupView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        
        if let image = photo.image {
            imageView.image = image
        } else if let photoID = photo.cloudReference?.recordID {
            let imageProvider = ImageProvider(photoID: photoID)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: imageProvider)
        }
        
        scrollView.zoomScale = 1.0
        
        deleteButton.isHidden = mode == .view
    }
    
//    private func showDeleteAlert() {
//        let actionSheetController: UIAlertController = UIAlertController()
//        actionSheetController.title = "deletePhotoAlertTitle".localized()
//
//        let cancelActionButton: UIAlertAction = UIAlertAction(title: "cancel".localized(), style: .cancel) { void in
//            actionSheetController.dismiss(animated: true, completion: nil)
//        }
//        actionSheetController.addAction(cancelActionButton)
//
//        let deleteActionButton: UIAlertAction = UIAlertAction(title: "delete".localized(), style: .destructive) { void in
//            self.dismiss(animated: true) {
//                self.delegate?.deletePhoto(photo: self.photo)
//            }
//        }
//        actionSheetController.addAction(deleteActionButton)
//
//        present(actionSheetController, animated: true, completion: nil)
//    }
}

extension FullPhotoController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
