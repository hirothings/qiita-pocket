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

        // bind
        self.refreshControll.rx.controlEvent(.valueChanged)
            .startWith(())
            .flatMap { Observable.just(UserSettings.getCurrentSearchTag()) }
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
        searchBar.text = UserSettings.getCurrentSearchTag()
        searchBar.enablesReturnKeyAutomatically = false
        navigationItem.titleView = searchBar
    }
    
    private func updateSearchState(tag: String) {
        UserSettings.setCurrentSearchTag(name: tag)
        
        let searchHistory = SearchHistory()
        searchHistory.add(history: tag)
    }
    
    
    // MARK: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // 検索モードのChildViewControllerをセット
        searchSettingVC = self.storyboard!.instantiateViewController(withIdentifier: "SearchSettingViewController") as! SearchSettingViewController
        self.addChildViewController(searchSettingVC)
        self.view.addSubview(searchSettingVC.view)
        searchSettingVC.didMove(toParentViewController: self)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 検索モードのChildViewControllerを削除
        searchSettingVC.willMove(toParentViewController: self)
        searchSettingVC.view.removeFromSuperview()
        searchSettingVC.removeFromParentViewController()
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 検索モードのChildViewControllerを削除
        searchSettingVC.willMove(toParentViewController: self)
        searchSettingVC.view.removeFromSuperview()
        searchSettingVC.removeFromParentViewController()
        
        searchBar.endEditing(true)
        updateSearchState(tag: searchBar.text!)
        viewModel.fetchTrigger.onNext(searchBar.text!)
    }
}
