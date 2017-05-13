//
//  ArticleListViewModel.swift
//  QiitaPocket
//
//  Created by hirothings on 2016/12/18.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

// TODO: インターフェースを作ってRecentとRankingのViewModel Classに分ける
class ArticleListViewModel {
    
    var articles = Variable<[Article]>([])
    let searchBarTitle = Variable("")
    var isLoading = Variable(false)
    var hasData = Variable(false)
    let scrollViewDidReachedBottom = PublishSubject<Void>()
    
    private let fetchRankingTrigger = PublishSubject<(keyword: String, page: String)>()
    private let fetchRecentTrigger = PublishSubject<(keyword: String, page: String)>()
    private let bag = DisposeBag()
    private var currentKeyword = ""
    private var nextPage = "1"

    
    init(fetchTrigger: PublishSubject<String>) {
        
        configureRanking()
        configureRecentArticle()
        
        fetchTrigger.bindNext { (keyword: String) in
            self.currentKeyword = keyword

            let searchType = UserSettings.getSearchType()
            switch searchType {
            case .rank:
                self.fetchRankingTrigger.onNext((keyword: keyword, page: "1"))
            case .recent:
                self.fetchRecentTrigger.onNext((keyword: keyword, page: self.nextPage))
            }
        }
        .addDisposableTo(bag)
        
        scrollViewDidReachedBottom
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                fetchTrigger.onNext(self.currentKeyword)
            })
            .disposed(by: bag)
    }

    
    func configureRanking() {
        var _articles: [Article] = []
        
        fetchRankingTrigger
            .do(onNext: { [unowned self] in
                self.isLoading.value = true
                self.searchBarTitle.value = $0.keyword // TODO: 検索設定追加
            })
            .flatMap {
                Articles.fetchWeeklyPost(with: $0.keyword, page: $0.page)
            }
            .do(onNext: { [unowned self] _ in
                self.isLoading.value = false
            })
            .observeOn(Dependencies.sharedInstance.mainScheduler)
            .subscribe(
                onNext: { [weak self] (model: Articles) in
                    guard let `self` = self else { return }

                    if model.items.isNotEmpty {
                        self.hasData.value = true
                        _articles += model.items
                        if let nextPage = model.nextPage {
                            self.fetchRankingTrigger.onNext((keyword: self.currentKeyword, page: nextPage))
                        }
                        else {
                            let sortedArticles = self.sortByStockCount(_articles)
                            let addedStateArticles = self.addReadLaterState(sortedArticles)
                            self.articles.value = addedStateArticles
                            _articles = []
                        }
                    }
                    else {
                        self.hasData.value = false
                    }
                },
                onError: { (error) in
                    // TODO: 判定が面倒なので、errorの種類自体をEnumにする
                    switch error {
                    case let qiitaError as QiitaAPIError:
                        self.showAlert(message: qiitaError.message)
                    case let connectionError as ConnectionError:
                        self.showAlert(message: connectionError.message)
                    default:
                        break
                    }
                    self.isLoading.value = false
                    self.configureRanking() // Disposeが破棄されるので、再度設定する TODO: 再起以外に方法はないのか？
                },
                onCompleted: {
                    print("Completed")
                }
            )
            .addDisposableTo(bag)
    }
    
    
    func configureRecentArticle() {
        fetchRecentTrigger
            .do(onNext: { [unowned self] tuple in
                self.isLoading.value = true
                self.searchBarTitle.value = tuple.keyword // TODO: 検索設定追加
            })
            .flatMap { tuple in
                Articles.fetch(with: tuple.keyword, page: tuple.page)
            }
            .do(onNext: { [unowned self] _ in
                self.isLoading.value = false
            })
            .observeOn(Dependencies.sharedInstance.mainScheduler)
            .subscribe(
                onNext: { [weak self] (model: Articles) in
                    guard let `self` = self else { return }
                    let _articles = model.items
                    if _articles.isNotEmpty {
                        self.hasData.value = true
                        let addedStateArticles = self.addReadLaterState(_articles)
                        self.articles.value += addedStateArticles
                    }
                    else {
                        self.hasData.value = false
                    }
                },
                onError: { (error) in
                    // TODO: 判定が面倒なので、errorの種類自体をEnumにする
                    switch error {
                    case let qiitaError as QiitaAPIError:
                        self.showAlert(message: qiitaError.message)
                    case let connectionError as ConnectionError:
                        self.showAlert(message: connectionError.message)
                    default:
                        break
                    }
                    self.isLoading.value = false
                    self.configureRecentArticle() // Disposeが破棄されるので、再度設定する
                },
                onCompleted: {
                    print("Completed")
                }
            )
            .addDisposableTo(bag)
    }
    
    
    // MARK: - Private Method

    /// ストック順に記事をソートする
    private func sortByStockCount(_ articles: [Article]) -> [Article] {
        let rankLimit: Int = (articles.count > 20) ? 20 : articles.count // 20件以上の場合、20件までに絞る
        var rankCount = 1
        
        let sortedArticles: [Article] = articles
            .flatMap { ($0, $0.stockCount) }
            .sorted { $0.1 > $1.1 }[0..<rankLimit]
            .map {
                $0.0.rank.value = rankCount
                rankCount += 1
                return $0.0
            }
        
        return sortedArticles
    }
    
    /// あとで読むステータスをarticleに付与する
    private func addReadLaterState(_ articles: [Article]) -> [Article] {
        let saveArtcleIDs: [String] = ArticleManager.getAll().map { $0.id }
        articles.forEach { (article: Article) in
            for id in saveArtcleIDs {
                if article.id == id {
                    article.hasSaved = true
                    break
                }
            }
        }
        return articles
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let defAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defAction)
        
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else { return }
        rootVC.present(alert, animated: true, completion: nil)
    }
}
