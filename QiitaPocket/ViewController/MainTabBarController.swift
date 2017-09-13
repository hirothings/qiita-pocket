//
//  MainTabBarController.swift
//  qiitareader
//
//  Created by hirothings on 2016/10/23.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let searchButton = tabBar.items?.first else { return }
        guard let readLaterButton = tabBar.items?.last else { return }
        
        // tabBar フォント調整
        let normalAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10),
            NSAttributedStringKey.foregroundColor: UIColor.disabled
        ]
        let selectedAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10),
            NSAttributedStringKey.foregroundColor: UIColor.theme
        ]
        searchButton.setTitleTextAttributes(normalAttributes, for: .normal)
        searchButton.setTitleTextAttributes(selectedAttributes, for: .selected)
        readLaterButton.setTitleTextAttributes(normalAttributes, for: .normal)
        readLaterButton.setTitleTextAttributes(selectedAttributes, for: .selected)
        
        // tabBar アイコン調整
        searchButton.image = #imageLiteral(resourceName: "ic-tab-search").withRenderingMode(.alwaysOriginal)
        readLaterButton.image = #imageLiteral(resourceName: "ic-tab-read-later").withRenderingMode(.alwaysOriginal)
        searchButton.selectedImage = #imageLiteral(resourceName: "ic-tab-search_selected").withRenderingMode(.alwaysOriginal)
        readLaterButton.selectedImage = #imageLiteral(resourceName: "ic-tab-read-later_selected").withRenderingMode(.alwaysOriginal)
    }

}
