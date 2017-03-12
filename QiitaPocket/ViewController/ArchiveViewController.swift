//
//  ArchiveViewController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/27.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ArchiveViewController: UIViewController, IndicatorInfoProvider {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "アーカイブ")
    }
}
