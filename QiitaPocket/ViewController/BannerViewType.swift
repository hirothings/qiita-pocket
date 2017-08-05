//
//  BannerViewType.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/04/16.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import GoogleMobileAds

protocol BannerViewType {
    func setupBannerView(containerView: UIView)
}

extension BannerViewType where Self: UIViewController {
    
    func setupBannerView(containerView: UIView) {
        let bannerView = GADBannerView()
        containerView.addSubview(bannerView)
        
        // Auto Layout
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        bannerView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        bannerView.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        bannerView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        // google AD
        // TODO: ifDEBUG
//      bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.adUnitID = "ca-app-pub-8842953390661934/7450873200"
        bannerView.rootViewController = self
        let gadRequest = GADRequest()
        bannerView.load(gadRequest)
    }
}
