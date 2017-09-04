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
    
    var hasData = Variable(false)
    var hasNextPage = Variable(false)
    let loadNextPageTrigger = PublishSubject<Void>()
    let alertTrigger = PublishSubject<String>()
    var firstLoad: Observable<[Article]>!
    var additionalLoad: Observable<[Article]>!
    
    lazy var isLoading: SharedSequence<DriverSharingStrategy, Bool> = {
        return self.isLoadingVariable.asDriver()
    }()
    
    var bottomViewHeight: CGFloat {
        switch self.searchType {
        case.rank:
            return 0
        case .recent:
            return 60
        }
    }
    
    var searchTitle: String {
        var text: String
        switch searchType {
        case .rank:
            text = "週間ランキング"
        case .recent:
            text = "新着順"
        }
        text += searchTag.isEmpty ? ": すべて" : ": \(searchTag)"
        return text
    }
    
    var titleColor: UIColor {
        switch searchType {
        case .rank:
            return UIColor.rankGold
        case .recent:
            return UIColor.theme
        }
    }

    private let fetchRankingTrigger = PublishSubject<(tag: String, period: SearchPeriod)>()
    private var fetchRecentTrigger = PublishSubject<(tag: String, page: Int)>()
    private let loadCompleteTrigger = PublishSubject<[Article]>()
    private var isLoadingVariable = Variable(false)

    private let bag = DisposeBag()
    private var articles: [Article] = []
    private var currentTag = ""
    private var currentPage: Int = 1
    
    private var searchType: SearchType {
        return UserSettings.getSearchType()
    }
    private var searchTag: String {
        return UserSettings.getcurrentTag()
    }
    private var searchPeriod: SearchPeriod {
        return UserSettings.getSearchPeriod()
    }

    
    init(fetchTrigger: PublishSubject<String>) {
        
        self.configureRecentArticle()
        self.configureRanking()
        
        fetchTrigger.bind(onNext: { [weak self] (tag: String) in
            guard let `self` = self else { return }
            self.isLoadingVariable.value = true
            self.resetItems(tag: tag)
            self.updateSearchState(tag: tag)
            
            switch self.searchType {
            case .rank:
                self.fetchRankingTrigger.onNext((tag: tag, period: self.searchPeriod))
            case .recent:
                self.fetchRecentTrigger.onNext((tag: tag, page: 1))
            }
        })
        .disposed(by: bag)
        
        firstLoad = loadCompleteTrigger
            .filter { _ in self.currentPage == 1 }
            .shareReplay(1)
        
        additionalLoad = loadCompleteTrigger
            .filter { _ in self.currentPage != 1 }
            .shareReplay(1)
    }
    
    
    // MARK: private method
    
    private func resetItems(tag: String) {
        self.currentTag = tag
        self.hasNextPage.value = false
        articles = []
        currentPage = 1
    }

    private func configureRanking() {
        fetchRankingTrigger
            .do(onNext: { [unowned self] tuple in
                self.isLoadingVariable.value = true
                self.resetItems(tag: tuple.tag)
            })
            .flatMap {
                Articles.fetchRankedPost(with: $0.tag, period: self.searchPeriod)
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
                        self.fetchRankingTrigger.onNext((tag: self.currentTag, period: self.searchPeriod))
                    }
                    else {
                        let sortedArticles = self.sortByStockCount(self.articles)
                        let addedStateArticles = self.addReadLaterState(sortedArticles)
                        self.articles = addedStateArticles
                        self.loadCompleteTrigger.onNext(self.articles)
                        self.isLoadingVariable.value = false
                    }
                },
                onError: { [weak self] (error: Error) in
                    guard let `self` = self else { return }
                    self.bindError(error)
                    self.hasData.value = false
                    self.isLoadingVariable.value = false
                    self.configureRanking() // Disposeが破棄されるので、再度設定する TODO: 再起以外に方法はないのか？
                }
            )
            .addDisposableTo(bag)
    }
    
    private func configureRecentArticle() {
        let nextPageRequest = loadNextPageTrigger
            .withLatestFrom(isLoading.asObservable())
            .filter { !$0 && self.hasNextPage.value && self.searchType == .recent }
            .flatMap { [weak self] _ -> Observable<(tag: String, page: Int)> in
                guard let `self` = self else { return Observable.empty() }
                self.currentPage += 1
                return Observable.of((tag: self.currentTag, page: self.currentPage))
            }
            .shareReplay(1)
        
        let request = Observable
            .of(fetchRecentTrigger, nextPageRequest)
            .merge()
            .shareReplay(1)
        
        request
            .do(onNext: { [unowned self] tuple in
                self.isLoadingVariable.value = true
            })
            .flatMap { tuple in
                Articles.fetch(with: tuple.tag, page: tuple.page)
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
                    self.isLoadingVariable.value = false
                },
                onError: { [weak self] (error) in
                    guard let `self` = self else { return }
                    self.bindError(error)
                    self.hasData.value = false
                    self.hasNextPage.value = false
                    self.isLoadingVariable.value = false
                    self.configureRecentArticle()
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
    
    private func bindError(_ error: Error) {
        switch error {
        case let error as QiitaAPIError:
            self.alertTrigger.onNext(error.message)
        case let error as ConnectionError:
            self.alertTrigger.onNext(error.message)
        default:
            self.alertTrigger.onNext(error.localizedDescription)
        }
    }
    
    private func updateSearchState(tag: String) {
        UserSettings.setcurrentTag(name: tag)
        let searchHistory = SearchHistory()
        searchHistory.add(tag: tag)
    }
}
