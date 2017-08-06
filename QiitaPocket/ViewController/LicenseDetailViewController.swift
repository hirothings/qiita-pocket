//
//  LicenseDetailViewController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/04/15.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit

class LicenseDetailViewController: UIViewController {
    
    let licenseText: String
    
    init?(title: String) {
        guard let licenseDetail = LicenseDetail(title: title) else {
            return nil
        }
        self.licenseText = licenseDetail.text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scrollView = UIScrollView()
        let contentView = UIView()
        let label = UILabel()
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(label)

        // Layout
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        scrollView.backgroundColor = UIColor.bg
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
        
        contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        contentView.heightAnchor.constraint(equalTo: self.view.heightAnchor).priority = UILayoutPriority.defaultLow
        contentView.backgroundColor = UIColor.white
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10.0).isActive = true
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0).isActive = true
        label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10.0).isActive = true
        label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10.0).isActive = true
        
        
        label.numberOfLines = 0
        label.text = self.licenseText
    }
}
