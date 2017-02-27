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
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = .black
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 1.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            
            oldCell?.label.textColor = UIColor.black.withAlphaComponent(0.6)
            newCell?.label.textColor = .black
        }

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
