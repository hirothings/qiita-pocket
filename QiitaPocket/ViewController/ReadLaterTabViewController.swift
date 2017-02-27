//
//  ReadLaterTabViewController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/27.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ReadLaterTabViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonBarView.removeFromSuperview()
        navigationController?.navigationBar.addSubview(buttonBarView)
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let readLaterVC = self.storyboard?.instantiateViewController(withIdentifier: "ReadLaterViewController")
        let archiveVC = self.storyboard?.instantiateViewController(withIdentifier: "ArchiveViewController")
        
        return [readLaterVC!, archiveVC!]
    }
}
