//
//  ArticleListViewController.swift
//  
//
//  Created by hirothings on 2016/05/04.
//
//

import UIKit
import RxSwift
import RxCocoa
import SafariServices


class ArticleListViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var noneDataLabel: UILabel!

    var refreshControll = UIRefreshControl()
    
    private var viewModel: ArticleListViewModel!
    private let dataSource = ArticleTableViewDataSource()
    
    private var fetchTrigger = PublishSubject<String>()
    private var searchArticleVC = SearchArticleViewController()
    private var searchBar: UISearchBar!
    private let bag = DisposeBag()
    private var nvc: ArticleListNavigationController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib: UINib = UINib(nibName: "ArticleTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ArticleTableViewCell")
        
        viewModel = ArticleListViewModel(fetchTrigger: fetchTrigger)
        
        viewModel.articles
            .asObservable()
            .bind(to: self.tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        tableView.delegate = dataSource
        
        tableView.rx.reachedBottom
            .asDriver()
            .drive(viewModel.scrollViewDidReachedBottom)
            .disposed(by: bag)
        
        tableView.estimatedRowHeight = 103.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.sectionHeaderHeight = 30.0
        tableView.isHidden = true
        noneDataLabel.isHidden = true
        activityIndicatorView.hidesWhenStopped = true
        
        nvc = self.navigationController as! ArticleListNavigationController
        searchBar = nvc.searchBar
        searchBar.delegate = self
        
        tableView.refreshControl = refreshControll
        
        
        // bind
        
        dataSource.isSwipingCell
            .bindNext { [unowned self] in
                self.tableView.panGestureRecognizer.isEnabled = !($0)
            }
            .addDisposableTo(bag)
        
        dataSource.didSwipeCell
            .bindNext { [unowned self] cell in
                self.tableView.beginUpdates()
                guard let indexPath = self.tableView.indexPath(for: cell) else { return }
                let article = self.viewModel.articles.value[indexPath.row]
                ArticleManager.add(readLater: article) // Realmに記事を保存
                self.viewModel.articles.value.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.tableView.endUpdates()
            }
            .addDisposableTo(bag)
        
        dataSource.didTapTableRow
            .bindNext { [unowned self] indexPath in
                let article = self.viewModel.articles.value[indexPath.row]
                guard let url = URL(string: article.url) else { return }
                let safariVC = SFSafariViewController(url: url)
                safariVC.modalPresentationStyle = .popover
                self.present(safariVC, animated: true, completion: nil)
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            .addDisposableTo(bag)
        
        refreshControll.rx.controlEvent(.valueChanged)
            .startWith(())
            .flatMap { Observable.just(UserSettings.getCurrentSearchTag()) }
            .bindTo(fetchTrigger)
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    // MARK: - Private Method
    
    // TODO: viewModelに処理移す
    private func updateSearchState(tag: String) {
        UserSettings.setCurrentSearchTag(name: tag)
        
        let searchHistory = SearchHistory()
        searchHistory.add(tag: tag)
    }
    
    /// 検索ViewControllerをセット
    private func setupSearchArticleVC() {
        searchArticleVC = self.storyboard!.instantiateViewController(withIdentifier: "SearchArticleViewController") as! SearchArticleViewController
        self.addChildViewController(searchArticleVC)
        self.view.addSubview(searchArticleVC.view)
        searchArticleVC.didMove(toParentViewController: self)
        
        // 検索履歴タップ時のイベント
        searchArticleVC.didSelectSearchHistory
            .subscribe(onNext: { [unowned self] (tag: String) in
                self.searchBar.text = tag
                self.updateSearchState(tag: tag)
                self.fetchTrigger.onNext(tag)
                self.searchBar.endEditing(true)
                self.searchBar.showsCancelButton = false
                self.removeSearchArticleVC()
                self.tableView.isHidden = true
            })
            .addDisposableTo(bag)
        
        nvc.unsetSettingButton()
    }
    
    /// 検索ViewControllerを削除
    private func removeSearchArticleVC() {
        searchArticleVC.willMove(toParentViewController: self)
        searchArticleVC.view.removeFromSuperview()
        searchArticleVC.removeFromParentViewController()
        nvc.setupSettingButton()
    }
    
    
    // MARK: - UISearchBarDelegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        setupSearchArticleVC()
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        removeSearchArticleVC()
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        removeSearchArticleVC()
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false

        updateSearchState(tag: searchBar.text!)
        fetchTrigger.onNext(searchBar.text!)
        self.tableView.isHidden = true
    }
}
