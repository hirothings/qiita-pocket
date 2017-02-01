//
//  ArticleListViewController.swift
//  
//
//  Created by hirothings on 2016/05/04.
//
//

import UIKit
import WebImage
import RxSwift


class ArticleListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, SwipeCellDelegate {

    @IBOutlet weak var table: UITableView!

    var articles: [Article] = []
    var postUrl: URL?
    var refreshControll = UIRefreshControl()
    
    private let bag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        table.rowHeight = 72.0
        table.separatorInset = UIEdgeInsets.zero
        
        let nib: UINib = UINib(nibName: "ArticleTableViewCell", bundle: nil)
        self.table.register(nib, forCellReuseIdentifier: "CustomCell")
        
        setupSearchBar()
        
        pullToRefresh()
        table.addSubview(refreshControll)
    }
    
    
    // MARK: - TableView Delegate

    /// tableViewの行数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    /// tableViewのcellを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! ArticleTableViewCell
        cell.article = articles[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    /// tableViewタップ時webViewに遷移する
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = articles[indexPath.row]

        postUrl = URL(string: article.url)
        performSegue(withIdentifier: "toWebView", sender: nil)
    }
    
    
    // MARK: - SwipeCellDelegate
    
    func didSwipeReadLater(at indexPath: IndexPath) {
        self.table.beginUpdates()
        self.articles.remove(at: indexPath.row)
        self.table.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        self.table.endUpdates()
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
    
    
    // MARK: - Private Method
    
    private func pullToRefresh() {
        self.refreshControll.rx.controlEvent(.valueChanged)
            .asObservable()
            .startWith(())
            .flatMap {
                Article.fetch()
            }
            .subscribe(onNext: { [unowned self] result in
                
                print("fetch done")
                
                self.articles = result
                self.table.delegate = self
                self.table.dataSource = self

                self.table.reloadData()
                
                self.refreshControll.endRefreshing()
            })
            .addDisposableTo(bag)
    }

    private func setupSearchBar() {
        let navigationBarFrame: CGRect = self.navigationController!.navigationBar.bounds
        let searchBar = UISearchBar(frame: navigationBarFrame)
        
        searchBar.delegate = self
        searchBar.placeholder = "タグを検索"
        searchBar.showsCancelButton = true
        searchBar.autocapitalizationType = .none
        searchBar.keyboardType = .default
        searchBar.tintColor = UIColor.gray
        navigationItem.titleView = searchBar
    }

    
    // MARK: - UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // TODO: API通信
    }
}
