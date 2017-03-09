//
//  ArticleListNavigationController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/09.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit

class ArticleListNavigationController: UINavigationController {
    
    var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
    }
    
    private func setupSearchBar() {
        let navigationBarFrame: CGRect = self.navigationBar.bounds
        searchBar = UISearchBar(frame: navigationBarFrame)
        
        searchBar.placeholder = "タグを検索"
        searchBar.showsCancelButton = false
        searchBar.autocapitalizationType = .none
        searchBar.keyboardType = .default
        searchBar.tintColor = UIColor.gray
        searchBar.text = UserSettings.getCurrentSearchTag()
        searchBar.enablesReturnKeyAutomatically = false
        for subView in searchBar.subviews {
            for secondSubView in subView.subviews {
                if secondSubView is UITextField {
                    secondSubView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                    break
                }
            }
        }
        self.navigationBar.topItem?.titleView = searchBar
    }
}
