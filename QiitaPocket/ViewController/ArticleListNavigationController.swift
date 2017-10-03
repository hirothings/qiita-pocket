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
        var posY: CGFloat
        if #available(iOS 11.0, *) {
            posY = 6
        }
        else {
            posY = 0
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        let button = UIButton(frame: CGRect(x: 0, y: posY, width: 44, height: 44))
        let image = #imageLiteral(resourceName: "ic-setting")
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(14.0, 14.0, 14.0, 14.0)
        button.imageView?.frame = CGRect(x: 14, y: 14, width: 16.0, height: 16.0)
        button.addTarget(self, action: #selector(didTapSettingButton(_:)), for: .touchUpInside)
        view.addSubview(button)
        return UIBarButtonItem(customView: view)
    }()
    
    private let logoImageItem: UIBarButtonItem = {
        var posY: CGFloat
        if #available(iOS 11.0, *) {
            posY = 12
        }
        else {
            posY = 8
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 32, height: 44))
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "logo"))
        logoImageView.frame = CGRect(x: 0, y: posY, width: 32, height: 32)
        logoImageView.contentMode = .scaleAspectFit
        view.addSubview(logoImageView)
        return UIBarButtonItem(customView: view)
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupLogoImage()
        setupSettingButton()
    }
    
    func unsetSettingButton() {
        navigationBar.topItem?.rightBarButtonItems?.removeAll()
    }
    
    func setupSettingButton() {
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = -10
        navigationBar.topItem?.rightBarButtonItems = [spacer, settingButton]
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
        searchBar.text = UserSettings.getcurrentTag()
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
    
    @objc func didTapSettingButton(_ sender: UITapGestureRecognizer) {
        let otherNVC = self.storyboard!.instantiateViewController(withIdentifier: "OtherNavigationController") as! OtherNavigationController
        self.present(otherNVC, animated: true, completion: nil)
    }
}
