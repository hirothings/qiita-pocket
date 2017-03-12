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
    
    private let settingButton: UIBarButtonItem = {
        let settingImageView = UIImageView(image: #imageLiteral(resourceName: "ic-setting"))
        settingImageView.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
        settingImageView.contentMode = .scaleAspectFit
        settingImageView.isUserInteractionEnabled = true
        return UIBarButtonItem(customView: settingImageView)
    }()
    
    private let logoImageItem: UIBarButtonItem = {
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "logo"))
        logoImageView.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        logoImageView.contentMode = .scaleAspectFit
        return UIBarButtonItem(customView: logoImageView)
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO:
        settingButton.rx.tap.bindNext { _ in
                print("TODO")
            }
            .addDisposableTo(bag)
        
        setupLogoImage()
        setupSearchBar()
        setupSettingButton()
    }
    
    func unsetSettingButton() {
        navigationBar.topItem?.rightBarButtonItems?.removeAll()
    }
    
    func setupSettingButton() {
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 10
        navigationBar.topItem?.rightBarButtonItems = [settingButton, spacer]
    }

    private func setupLogoImage() {
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = -10.0
        navigationBar.topItem?.leftBarButtonItems = [spacer, logoImageItem]
    }
    
    private func setupSearchBar() {
        searchBar.placeholder = "キーワードを入力"
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
