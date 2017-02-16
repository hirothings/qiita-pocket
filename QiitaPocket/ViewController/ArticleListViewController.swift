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
import RxCocoa


class ArticleListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwipeCellDelegate, UISearchBarDelegate {

    @IBOutlet weak var table: UITableView!

    var articles: [Article] = []
    var postUrl: URL?
    var refreshControll = UIRefreshControl()
    
    private let viewModel = ArticleListViewModel()
    private var searchSettingVC = SearchSettingViewController()
    private let bag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.rowHeight = 72.0
        table.separatorInset = UIEdgeInsets.zero
        
        let nib: UINib = UINib(nibName: "ArticleTableViewCell", bundle: nil)
        self.table.register(nib, forCellReuseIdentifier: "CustomCell")
        
        // 検索モードのChildViewControllerをセット
        searchSettingVC = self.storyboard!.instantiateViewController(withIdentifier: "SearchSettingViewController") as! SearchSettingViewController
        self.addChildViewController(searchSettingVC)
        self.view.addSubview(searchSettingVC.view)
        searchSettingVC.didMove(toParentViewController: self)
        searchSettingVC.view.alpha = 0
        
        // bind
        self.refreshControll.rx.controlEvent(.valueChanged)
            .startWith(())
            .bindTo(self.viewModel.fetchTrigger)
            .addDisposableTo(bag)

        self.viewModel.fetchNotification
            .subscribe(onNext: { [unowned self] articles in

                print("fetch done")

                self.articles = articles
                self.table.delegate = self
                self.table.dataSource = self

                self.table.reloadData()

                self.refreshControll.endRefreshing()
            })
            .addDisposableTo(bag)

        setupSearchBar()
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchSettingVC.view.fadeIn()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchSettingVC.view.fadeOut()
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.fetchTagPostsTrigger.onNext(searchBar.text!)
    }

}
