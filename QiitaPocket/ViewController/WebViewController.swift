//
//  WebViewController.swift
//  qiitareader
//
//  Created by hirothings on 2016/05/07.
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
    
    var webview = WKWebView()
    var url: URL?
    
    // TODO: VCのイニシャライザでurl渡してみる

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webview.navigationDelegate = self
        webview.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(webview)
        
        // 上辺の制約
        webview.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0.0).isActive = true
        // 下辺の制約
        webview.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0.0).isActive = true
        // 左辺の制約
        webview.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0.0).isActive = true
        // 右辺の制約
        webview.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0.0).isActive = true
    
        
        guard let _ = url else {
            return
        }
        
        let request = URLRequest(url: url!)
        webview.load(request)
        
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
        
        let flexbleItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        goBackBtn = UIBarButtonItem(image: backBtnImage, style: .plain, target: self, action: #selector(goBack))
        goFowardBtn = UIBarButtonItem(image: fowardBtnImage, style: .plain, target: self, action: #selector(goFoward))
        refreshBtn = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webview.canGoBack {
            goBackBtn.tintColor = nil
        } else {
            goBackBtn.tintColor = UIColor.gray
        }

        
        if webview.canGoForward {
            goFowardBtn.tintColor = nil
        } else {
            goFowardBtn.tintColor = UIColor.gray
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            if navigationAction.targetFrame == nil || !(navigationAction.targetFrame!.isMainFrame) {
                webview.load(URLRequest.init(url: url))
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
}
