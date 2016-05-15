//
//  WebViewController.swift
//  qiitareader
//
//  Created by 坂本 浩 on 2016/05/07.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    var goBackBtn = UIBarButtonItem()
    var goFowardBtn = UIBarButtonItem()
    var refreshBtn = UIBarButtonItem()
    
    var webview: WKWebView!
    var url: NSURL?    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webview = WKWebView()
        webview.navigationDelegate = self
        webview.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(webview!)
        
        // 上辺の制約
        webview.topAnchor.constraintEqualToAnchor(containerView.topAnchor, constant: 0.0).active = true
        // 下辺の制約
        webview.bottomAnchor.constraintEqualToAnchor(containerView.bottomAnchor, constant: 0.0).active = true
        // 左辺の制約
        webview.leadingAnchor.constraintEqualToAnchor(containerView.leadingAnchor, constant: 0.0).active = true
        // 右辺の制約
        webview.trailingAnchor.constraintEqualToAnchor(containerView.trailingAnchor, constant: 0.0).active = true
    
        
        guard let _ = url else {
            return
        }
        
        let request = NSURLRequest(URL: url!)
        webview.loadRequest(request)
        
        // スワイプで戻る・進むできるようにする
        webview.allowsBackForwardNavigationGestures = true
        
        // ツールバーの生成
        creatToolbarItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func creatToolbarItems() {
        
        let backBtnImage = UIImage(named: "back")
        let fowardBtnImage = UIImage(named: "next")
        
        let flexbleItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        goBackBtn = UIBarButtonItem(image: backBtnImage, style: .Plain, target: self, action: #selector(goBack))
        goFowardBtn = UIBarButtonItem(image: fowardBtnImage, style: .Plain, target: self, action: #selector(goFoward))
        refreshBtn = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(refresh))
        
        toolbar.items = [goBackBtn, goFowardBtn, flexbleItem, refreshBtn]
    }
    
    func goBack() {
        if webview.canGoBack {
            webview.goBack()
        }
    }
    
    func goFoward() {
        if webview.canGoForward {
            webview.goForward()
        }
    }
    
    func refresh() {
        webview.reload()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        if webview.canGoBack {
            goBackBtn.tintColor = nil
        } else {
            goBackBtn.tintColor = UIColor.grayColor()
        }
        
        if webview.canGoForward {
            goFowardBtn.tintColor = nil
        } else {
            goFowardBtn.tintColor = UIColor.grayColor()
        }
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.URL else {
            decisionHandler(.Cancel)
            return
        }
        
        if navigationAction.navigationType == WKNavigationType.LinkActivated {
            if navigationAction.targetFrame == nil || !(navigationAction.targetFrame!.mainFrame) {
                webview.loadRequest(NSURLRequest.init(URL: url))
                decisionHandler(.Cancel)
                return
            }
        }
        
        decisionHandler(.Allow)
    }
}
