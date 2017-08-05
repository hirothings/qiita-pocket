//
//  OtherViewController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/04/16.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit

class OtherViewController: UIViewController, BannerViewType {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "その他"
        setupBannerView(containerView: self.view)
    }
}
