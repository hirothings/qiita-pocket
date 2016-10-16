//
//  ArticleListViewController.swift
//  
//
//  Created by 坂本 浩 on 2016/05/04.
//
//

import UIKit
import WebImage
import RxSwift


class ArticleListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var table: UITableView!

    var articles: [Article] = []
    var postUrl: URL?
    var refreshControll: UIRefreshControl!
    
    private let bag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.delegate = self
        table.dataSource = self
        
        table.rowHeight = 40.0
        table.separatorInset = UIEdgeInsets.zero
        title = "新着記事"
        
        refreshControll = UIRefreshControl()
        refreshControll.attributedTitle = NSAttributedString(string: "下に引っ張って更新")
        pullToRefresh()
        
        table.addSubview(refreshControll)
    }
    
    /// tableViewの行数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    /// tableViewのcellを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = table.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        let article = articles[indexPath.row]
        
        
        // ほんとはcell内で生成したほうが綺麗
        
        // 投稿者イメージの生成
        let url = URL(string: article.profile_image_url)
        let imageView = table.viewWithTag(1) as! UIImageView
        imageView.sd_setImage(with: url)
        
        // 投稿タイトルの生成
        let label = table.viewWithTag(2) as! UILabel
        label.text = article.title
        label.lineBreakMode = .byTruncatingTail
        
        return cell
    }
    
    /// tableViewタップ時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let article = articles[indexPath.row]

        postUrl = URL(string: article.url)
        performSegue(withIdentifier: "toWebView", sender: nil)
    }
    
    /// 各segueの設定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.identifier! {
            case "toWebView":
                let webView: WebViewController = segue.destination as! WebViewController
                webView.url = postUrl
            default:
                break
        }
    }
    
    func pullToRefresh() {
        
        self.refreshControll.rx.controlEvent(.valueChanged)
            .asObservable()
            .startWith(())
            .flatMap {
                return Article.fetch()
            }
            .subscribe(onNext: { [unowned self] result in
                self.articles = result
                self.refreshControll.endRefreshing()
                self.table.reloadData()
            })
            .addDisposableTo(bag)
    }


}
