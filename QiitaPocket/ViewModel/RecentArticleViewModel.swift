//
//  RecentArticleViewModel.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/05/13.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RecentArticleViewModel: FetchArticleType {
    
    var articles: [Article] = []
    let searchBarTitle = Variable("")
    var isLoading = Variable(false)
    var hasData = Variable(false)
    let scrollViewDidReachedBottom = PublishSubject<Void>()
    let alertTrigger = PublishSubject<String>()
    let loadCompleteTrigger = PublishSubject<[Article]>()
    
    private var fetchRecentTrigger = PublishSubject<(keyword: String, page: String)>()
    private let bag = DisposeBag()
    private var currentKeyword = ""
    private var nextPage: Int? = 1
    
    
    init(fetchTrigger: PublishSubject<String>) {
        
        fetchTrigger
            .map { [unowned self] keyword in
                self.resetItems(keyword: keyword)
                return (keyword: self.currentKeyword, page: "\(1)")
            }
            .bind(to: fetchRecentTrigger)
            .disposed(by: bag)
        
        configureRecentArticle()
        bindPagination()
    }
    
    
    // MARK: private method
    
    private func resetItems(keyword: String) {
        self.currentKeyword = keyword
        articles = []
        nextPage = 1
    }
    
    private func bindPagination() {
        scrollViewDidReachedBottom
            .filter { self.nextPage != nil }
            .map { [unowned self] _ in
                print("scrollView下まできた")
                return (keyword: self.currentKeyword, page: "\(self.nextPage!)")
            }
            .bind(to: fetchRecentTrigger)
            .disposed(by: bag)
    }

    
    private func configureRecentArticle() {
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
                        self.articles += addedStateArticles
                        // TODO: 不要かもしれない
                        if let nextPage = model.nextPage {
                            self.nextPage! = Int(nextPage)!
                        }
                        else {
                            self.nextPage = nil
                        }
                        self.loadCompleteTrigger.onNext(self.articles)
                    }
                    else {
                        self.nextPage = nil
                        self.hasData.value = false
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
                    self.configureRecentArticle() // Disposeが破棄されるので、再度設定する
                },
                onCompleted: {
                    print("Completed")
                }
            ).addDisposableTo(bag)
    }
}
