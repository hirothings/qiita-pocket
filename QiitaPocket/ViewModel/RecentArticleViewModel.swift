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
    
    var articles = Variable<[Article]>([])
    let searchBarTitle = Variable("")
    var isLoading = Variable(false)
    var hasData = Variable(false)
    let scrollViewDidReachedBottom = PublishSubject<Void>()
    let alertTrigger = PublishSubject<String>()
    
    private var fetchRecentTrigger: Observable<(keyword: String, page: String)> = Observable.empty()
    private let bag = DisposeBag()
    private var currentKeyword = ""
    private var nextPage = "1"
    
    init(fetchTrigger: PublishSubject<String>) {
        
        fetchRecentTrigger = fetchTrigger.asObserver()
            .map { [unowned self] keyword in
                return (keyword, self.nextPage)
            }
        
        configureRecentArticle()
        
        scrollViewDidReachedBottom
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                fetchTrigger.onNext(self.currentKeyword)
            })
            .disposed(by: bag)
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
            )
            .addDisposableTo(bag)
    }
}
