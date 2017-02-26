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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var noneDataLabel: UILabel!

    var articles: [Article] = []
    var postUrl: URL?
    var refreshControll = UIRefreshControl()
    
    private let viewModel = ArticleListViewModel()
    private var searchArticleVC = SearchArticleViewController()
    private let bag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 72.0
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.isHidden = true
        noneDataLabel.isHidden = true
        activityIndicatorView.hidesWhenStopped = true
        
        let nib: UINib = UINib(nibName: "ArticleTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        
        // bind
        refreshControll.rx.controlEvent(.valueChanged)
            .startWith(())
            .flatMap { Observable.just(UserSettings.getCurrentSearchTag()) }
            .bindTo(self.viewModel.fetchTrigger)
            .addDisposableTo(bag)

        viewModel.fetchSucceed
            .subscribe(onNext: { [unowned self] articles in

                print("fetch done")

                self.articles = articles
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                self.tableView.isHidden = false
                self.refreshControll.endRefreshing()
            })
            .addDisposableTo(bag)
        
        viewModel.isLoading.asDriver()
            .do(onNext: { [weak self] in
                self?.noneDataLabel.isHidden = $0
            })
            .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
            .addDisposableTo(bag)
            
        viewModel.isLoading.asDriver()
            .drive(activityIndicatorView.rx.isAnimating)
            .addDisposableTo(bag)
        
        viewModel.hasData.asObservable()
            .skip(1)
            .bindTo(noneDataLabel.rx.isHidden)
            .addDisposableTo(bag)

        setupSearchBar()
        tableView.refreshControl = refreshControll
    }


    // MARK: - TableView Delegate

    /// tableViewの行数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    /// tableViewのcellを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! ArticleTableViewCell
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
        tableView.beginUpdates()
        
        let article = articles[indexPath.row]
        ArticleManager.update(article: article) // Realmに記事を保存
        
        articles.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        tableView.endUpdates()
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
        searchBar.showsCancelButton = false
        searchBar.autocapitalizationType = .none
        searchBar.keyboardType = .default
        searchBar.tintColor = UIColor.gray
        searchBar.text = UserSettings.getCurrentSearchTag()
        searchBar.enablesReturnKeyAutomatically = false
        for subView in searchBar.subviews {
            for secondSubView in subView.subviews {
                if secondSubView is UITextField {
                    secondSubView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
                    break
                }
            }
        }
        navigationItem.titleView = searchBar
    }
    
    private func updateSearchState(tag: String) {
        UserSettings.setCurrentSearchTag(name: tag)
        
        let searchHistory = SearchHistory()
        searchHistory.add(tag: tag)
    }
    
    
    // MARK: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        // 検索モードのChildViewControllerをセット
        searchArticleVC = self.storyboard!.instantiateViewController(withIdentifier: "SearchArticleViewController") as! SearchArticleViewController
        self.addChildViewController(searchArticleVC)
        self.view.addSubview(searchArticleVC.view)
        searchArticleVC.didMove(toParentViewController: self)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        // 検索モードのChildViewControllerを削除
        searchArticleVC.willMove(toParentViewController: self)
        searchArticleVC.view.removeFromSuperview()
        searchArticleVC.removeFromParentViewController()
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 検索モードのChildViewControllerを削除
        searchArticleVC.willMove(toParentViewController: self)
        searchArticleVC.view.removeFromSuperview()
        searchArticleVC.removeFromParentViewController()
        
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false

        updateSearchState(tag: searchBar.text!)
        viewModel.fetchTrigger.onNext(searchBar.text!)
        self.tableView.isHidden = true
    }
}
