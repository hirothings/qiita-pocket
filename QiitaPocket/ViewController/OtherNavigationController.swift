//
//  OtherNavigationController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/04/02.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit

class OtherNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "閉じる", style: .plain, target: self, action: #selector(didTapCloseButton))
    }
    
    @objc func didTapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
}
