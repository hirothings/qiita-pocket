//
//  ArchiveViewController.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/27.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import XLPagerTabStrip

class ArchiveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    
    var articles: Results<Article> = {
        return ArticleManager.getArchives()
    }()
    
    var postUrl: URL?
    var notificationToken: NotificationToken?
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 103.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorInset = UIEdgeInsets.zero
        
        let nib: UINib = UINib(nibName: "ArchiveTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Realm更新時、reloadDataする
        notificationToken = articles.addNotificationBlock { [weak self] (change: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            
            switch change {
            case .initial:
                tableView.reloadData()
            case .update(_, deletions: _, insertions: _, modifications: _):
                tableView.reloadData()
            case .error(let error):
                // TODO: エラー処理
                fatalError("\(error)")
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    deinit {
        notificationToken?.stop()
    }
    
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "アーカイブ")
    }
    
    
    // MARK: - TableView Delegate
    
    /// tableViewの行数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    /// tableViewのcellを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! ArchiveTableViewCell
        cell.article = articles[indexPath.row]
        
        return cell
    }
    
    /// tableViewタップ時webViewに遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        
        postUrl = URL(string: article.url)
        performSegue(withIdentifier: "toWebView", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "toWebView":
            let webView: WebViewController = segue.destination as! WebViewController
            webView.url = postUrl
            webView.hidesBottomBarWhenPushed = true
        default:
            break
        }
    }
}
