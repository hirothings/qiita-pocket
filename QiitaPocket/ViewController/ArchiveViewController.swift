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
import SafariServices

class ArchiveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, IndicatorInfoProvider, ArticleCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var articles: Results<Article> = {
        return ArticleManager.getArchives()
    }()
    
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
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
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
        cell.delegate = self
        
        return cell
    }
    
    /// tableViewタップ時webViewに遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]
        
        guard let url = URL(string: article.url) else { return }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - ArticleCellDelegate
    
    func didTapActionButton(on cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let article = articles[indexPath.row]
        ArticleManager.delete(article: article)
    }

}
