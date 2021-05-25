//
//  OnboardingController.swift
//  My Secret
//
//  Created by Petr on 17.08.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

//protocol OnboardingControllerDelegate: class {
//    func closeOnboarding()
//}

class OnboardingController: UIViewController {
//    weak var coordinator: OnboardingDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipButton: UIButton!
    //    @IBOutlet var swipeGestureRecognizer: UISwipeGestureRecognizer!

    
    var storiesByDate: [String: [Story]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skipButton.setTitle("skip".localized(), for: .normal)
        
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width * 3, height: 1.0)
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        //        var scrollViewHeight = screenHeight - 72
        
        
        for i in 0...2 {
            switch i {
            case 0:
                let startOnboardingView = StartOnboardingView(frame: CGRect(x: screenWidth * CGFloat(i), y:  0, width: screenWidth, height: screenHeight))
                scrollView.addSubview(startOnboardingView)
            case 1:
                let firstOnboardingView = FirstOnboardingView(frame: CGRect(x: screenWidth * CGFloat(i), y:  0, width: screenWidth, height: screenHeight))
                scrollView.addSubview(firstOnboardingView)
            case 2:
                let secondOnboardingView = SecondOnboardingView(frame: CGRect(x: screenWidth * CGFloat(i), y:  0, width: screenWidth, height: screenHeight))
                    secondOnboardingView.delegate = self
                scrollView.addSubview(secondOnboardingView)
            default:
                break
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.setContentOffset(CGPoint.zero, animated: false)
        //        swipeGestureRecognizer.isEnabled = false
        
        //        UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.statusBar
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func didTapSkipButton(_ sender: Any) {
        if Global.isOnboardingWatched {
            dismiss(animated: true)
        } else {
            Global.isOnboardingWatched = true
            UIApplication.shared.windows.first?.rootViewController = TabBarController(storiesByDate: storiesByDate)
        }
    }
    
    @IBAction func didLeftSwipe(_ sender: UISwipeGestureRecognizer) {
//        coordinator?.closeOnboarding()
    }
}

extension OnboardingController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let screenWidth = UIScreen.main.bounds.width
        switch scrollView.contentOffset.x {
        case 0 ..< screenWidth / 2 :
            pageControl.currentPage = 0
        //            swipeGestureRecognizer.isEnabled = false
        case screenWidth / 2 ..< screenWidth * 1.5:
            pageControl.currentPage = 1
        //            swipeGestureRecognizer.isEnabled = false
        case screenWidth * 1.5 ... screenWidth * 2:
            pageControl.currentPage = 2
        //            swipeGestureRecognizer.isEnabled = false
        case screenWidth * 2.1 ... screenWidth * 3:
            pageControl.currentPage = 2
//            coordinator?.closeOnboarding()
        //            swipeGestureRecognizer.isEnabled = true
        default:
            break
        }
    }
}

extension OnboardingController: SecondOnboardingViewDelegate {
    func didTapBegin() {
        if Global.isOnboardingWatched {
            dismiss(animated: true)
        } else {
            Global.isOnboardingWatched = true
            UIApplication.shared.windows.first?.rootViewController = TabBarController(storiesByDate: storiesByDate)
        }
        
    }
}
