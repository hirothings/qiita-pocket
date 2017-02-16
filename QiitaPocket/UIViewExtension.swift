//
//  UIViewExtension.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/16.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit

extension UIView {

    func fadeIn(duration: Double = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        })
    }
    
    func fadeOut(duration: Double = 0.2) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0.0
        })
    }
}
