//
//  TabBarController.swift
//  My Secret
//
//  Created by Petr on 28.04.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    init(storiesByDate: [String: [Story]]) {
        super.init(nibName: nil, bundle: nil)
        dairyController.storiesByDate = storiesByDate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var dairyController: DairyController = {
        let dairyController = DairyController.storyboard()
        return dairyController
    }()
    
    lazy var dairyNavigationController: NavigationController = {
        let dairyNavigationController = NavigationController(rootViewController: dairyController)
        return dairyNavigationController
    }()
    
    lazy var searchController: SearchController = {
        let searchController = SearchController.storyboard()
        return searchController
    }()
    
    lazy var forYouController: ForYouController = {
        let forYouController = ForYouController.storyboard()
        return forYouController
    }()
    
    lazy var forYouNavigationController: NavigationController = {
        let forYouNavigationController = NavigationController(rootViewController: forYouController)
        return forYouNavigationController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        dairyNavigationController.tabBarItem = UITabBarItem(title: "Dairy".localized(), image: #imageLiteral(resourceName: "DairyOff"), selectedImage: #imageLiteral(resourceName: "DairyOn"))
        searchController.tabBarItem = UITabBarItem(title: "Search".localized(), image: #imageLiteral(resourceName: "SearchOff"), selectedImage: #imageLiteral(resourceName: "SearchOn"))
        forYouNavigationController.tabBarItem = UITabBarItem(title: "ForYou".localized(), image: #imageLiteral(resourceName: "ForYouOff"), selectedImage: #imageLiteral(resourceName: "ForYouOn"))
        viewControllers = [dairyNavigationController, searchController, forYouNavigationController]
        tabBar.tintColor = Palette.gray
//        tabBar.barStyle = .default
//        tabBar.contentMode = .scaleAspectFill
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        authorizationNavigationController.viewControllers = [RegistrationController.storyboard() ]
//        authorizationNavigationController.modalPresentationStyle = .fullScreen
//        present(authorizationNavigationController, animated: false)
    }
}
