//
//  ArticleListViewModel.swift
//  QiitaPocket
//
//  Created by hirothings on 2016/12/18.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import Foundation
import RxSwift

class ArticleListViewModel {
    
    let fetchTrigger = PublishSubject<String>()
    let fetchSucceed = PublishSubject<[Article]>()
    let searchBarTitle = Variable("")
    var isLoading = Variable(false)
    var hasData = Variable(false)
    
    private let fetchRankingTrigger = PublishSubject<(keyword: String, page: String)>()
    private let fetchRecentTrigger = PublishSubject<String>()
    private let bag = DisposeBag()

    
    init() {
        
        configureRanking()
        configureRecentArticle()
        
        // TODO: model化
        fetchTrigger.bindNext { (keyword: String) in
            if let searchType = UserSettings.getSearchType() {
                switch searchType {
                case .rank:
                    self.fetchRankingTrigger.onNext((keyword: keyword, page: "1"))
                case .recent:
                    self.fetchRecentTrigger.onNext(keyword)
                }
            }
            else {
                self.fetchRankingTrigger.onNext((keyword: keyword, page: "1"))
            }
        }
        .addDisposableTo(bag)
    }

    
    func configureRanking() {
        var currentKeyword: String = ""
        
        fetchRankingTrigger
            .do(onNext: { [unowned self] in
                self.isLoading.value = true
                self.searchBarTitle.value = $0.keyword // TODO: 検索設定追加
                currentKeyword = $0.keyword // キャプチャできる用にスコープ外にキーワードを渡す
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
                    let articles = model.items
                    if articles.isNotEmpty {
                        self.hasData.value = true
                        if let nextPage = model.nextPage {
                            self.fetchRankingTrigger.onNext((keyword: currentKeyword, page: nextPage))
                        }
                        else {
                            let sortedArticles = self.sortByStockCount(articles)
                            self.fetchSucceed.onNext(sortedArticles)
                        }
                    }
                    else {
                        self.hasData.value = false
                    }
                },
                onError: { (error) in
                    print("error")
                },
                onCompleted: {
                    print("Completed")
                }
            )
            .addDisposableTo(bag)
    }
    
    
    func configureRecentArticle() {
        fetchRecentTrigger
            .do(onNext: { [unowned self] tag in
                self.isLoading.value = true
                self.searchBarTitle.value = tag // TODO: 検索設定追加
            })
            .flatMap { tag in
                Articles.fetch(with: tag)
            }
            .do(onNext: { [unowned self] _ in
                self.isLoading.value = false
            })
            .observeOn(Dependencies.sharedInstance.mainScheduler)
            .subscribe(
                onNext: { [weak self] (model: Articles) in
                    guard let `self` = self else { return }
                    let articles = model.items
                    if articles.isNotEmpty {
                        self.hasData.value = true
                        self.fetchSucceed.onNext(articles)
                    }
                    else {
                        self.hasData.value = false
                    }
                },
                onError: { (error) in
                    print("error")
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
        let sortedArticles = articles
            .flatMap { ($0, $0.stockCount) }
            .sorted { $0.1 > $1.1 }[0..<rankLimit]
            .map { $0.0 }
        
        return sortedArticles
    }
}
