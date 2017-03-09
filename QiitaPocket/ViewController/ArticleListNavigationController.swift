//
//  ArticleListNavigationController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/09.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ArticleListNavigationController: UINavigationController {
    
    var searchBar = UISearchBar()
    private let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLogoImage()
        setupSearchBar()
        setupSettingButton()
    }
    
    private func setupLogoImage() {
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "logo"))
        logoImageView.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        logoImageView.contentMode = .scaleAspectFit
        let imageItem = UIBarButtonItem(customView: logoImageView)
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = -10.0
        navigationBar.topItem?.leftBarButtonItems = [spacer, imageItem]
    }
    
    private func setupSettingButton() {
        let settingImageView = UIImageView(image: #imageLiteral(resourceName: "ic-setting"))
        settingImageView.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
        settingImageView.contentMode = .scaleAspectFit
        settingImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event.bindNext { _ in
            print("TODO")
        }
        .addDisposableTo(bag)
        settingImageView.addGestureRecognizer(tapGesture)
        let rightButton = UIBarButtonItem(customView: settingImageView)
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 10
        navigationBar.topItem?.rightBarButtonItems = [rightButton, spacer]
    }
    
    private func setupSearchBar() {
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
