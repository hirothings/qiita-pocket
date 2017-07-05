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

class ArticleListViewModel {
    
    var articles: [Article] = []
    let searchBarTitle = Variable("")
    var isLoading = Variable(false)
    var hasData = Variable(false)
    let loadNextPageTrigger = PublishSubject<Void>()
    let alertTrigger = PublishSubject<String>()
    let loadCompleteTrigger = PublishSubject<[Article]>()
    var currentPage: Int = 1
    var hasNextPage = Variable(false)

    private let fetchRankingTrigger = PublishSubject<(keyword: String, page: Int)>()
    private var fetchRecentTrigger = PublishSubject<(keyword: String, page: Int)>()

    private let bag = DisposeBag()
    private var currentKeyword = ""

    
    init(fetchTrigger: PublishSubject<String>) {
        
        self.configureRecentArticle()
        self.configureRanking()
        
        fetchTrigger.bind(onNext: { [weak self] (keyword: String) in
            guard let `self` = self else { return }
            self.isLoading.value = true
            self.resetItems(keyword: keyword)
            
            let searchType = UserSettings.getSearchType()
            switch searchType {
            case .rank:
                self.fetchRankingTrigger.onNext((keyword: keyword, page: 1))
            case .recent:
                self.fetchRecentTrigger.onNext((keyword: keyword, page: 1))
            }
        })
        .disposed(by: bag)
    }
    
    
    // MARK: private method
    
    private func resetItems(keyword: String) {
        self.currentKeyword = keyword
        self.searchBarTitle.value = keyword
        self.hasNextPage.value = false
        articles = []
        currentPage = 1
    }

    func configureRanking() {
        fetchRankingTrigger
            .do(onNext: { [unowned self] tuple in
                self.isLoading.value = true
                self.resetItems(keyword: tuple.keyword)
            })
            .flatMap {
                Articles.fetchWeeklyPost(with: $0.keyword, page: $0.page)
            }
            .observeOn(Dependencies.sharedInstance.mainScheduler)
            .subscribe(
                onNext: { [weak self] (model: Articles) in
                    guard let `self` = self else { return }
                    
                    if model.items.isEmpty {
                        self.hasData.value = false
                        return
                    }

                    self.hasData.value = true
                    self.articles += model.items
                    if let _ = model.nextPage {
                        self.fetchRankingTrigger.onNext((keyword: self.currentKeyword, page: self.currentPage + 1))
                    }
                    else {
                        let sortedArticles = self.sortByStockCount(self.articles)
                        let addedStateArticles = self.addReadLaterState(sortedArticles)
                        self.articles = addedStateArticles
                        self.loadCompleteTrigger.onNext(self.articles)
                        self.isLoading.value = false
                    }
                },
                onError: { (error) in
                    // TODO: 判定が面倒なので、errorの種類自体をEnumにする
                    switch error {
                    case let qiitaError as QiitaAPIError:
                        self.alertTrigger.onNext(qiitaError.message)
                    case let connectionError as ConnectionError:
                        self.alertTrigger.onNext(connectionError.message)
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
    
    private func configureRecentArticle() {
        let nextPageRequest = loadNextPageTrigger
            .withLatestFrom(isLoading.asObservable())
            .filter { !$0 && self.hasNextPage.value && UserSettings.getSearchType() == .recent }
            .flatMap { [weak self] _ -> Observable<(keyword: String, page: Int)> in
                guard let `self` = self else { return Observable.empty() }
                self.currentPage += 1
                return Observable.of((keyword: self.currentKeyword, page: self.currentPage))
            }
            .shareReplay(1)
        
        let request = Observable
            .of(fetchRecentTrigger, nextPageRequest)
            .merge()
            .shareReplay(1)
        
        request
            .do(onNext: { [unowned self] tuple in
                self.isLoading.value = true
            })
            .flatMap { tuple in
                Articles.fetch(with: tuple.keyword, page: tuple.page)
            }
            .observeOn(Dependencies.sharedInstance.mainScheduler)
            .subscribe(
                onNext: { [weak self] (model: Articles) in
                    guard let `self` = self else { return }
                    let _articles = model.items
                    if _articles.isNotEmpty {
                        self.hasData.value = true
                        let addedStateArticles = self.addReadLaterState(_articles)
                        self.articles += addedStateArticles
                        self.loadCompleteTrigger.onNext(self.articles)
                    }
                    else {
                        self.hasData.value = false
                    }
                    self.hasNextPage.value = (model.nextPage != nil)
                    self.isLoading.value = false
                },
                onError: { (error) in
                    // TODO: 判定が面倒なので、errorの種類自体をEnumにする
                    switch error {
                    case let qiitaError as QiitaAPIError:
                        self.alertTrigger.onNext(qiitaError.message)
                    case let connectionError as ConnectionError:
                        self.alertTrigger.onNext(connectionError.message)
                    default:
                        break
                    }
                    self.isLoading.value = false
                    //                    self.configureRecentArticle()
                    // TODO: Disposeが破棄されるので、再度設定する
            },
                onCompleted: {
                    print("Completed")
            }
        ).addDisposableTo(bag)
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

}
