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
    
    let fetchTrigger = PublishSubject<Void>()
    let fetchTagPostsTrigger = PublishSubject<String>()
    let fetchNotification = PublishSubject<[Article]>()
    let searchBarTitle = Variable("")
    
    private let bag = DisposeBag()
    
    init() {
        fetchTrigger
            .flatMap {
                Article.fetch()
            }
            .observeOn(Dependencies.sharedInstance.mainScheduler)
            .subscribe(
                onNext: { [weak self] (articles: [Article]) in
                    guard let `self` = self else { return }
                    dump(articles)
                    self.fetchNotification.onNext(articles)
                },
                onError: { (error) in
                    print("error")
                },
                onCompleted: {
                    print("Completed")
                })
                .addDisposableTo(bag)

        
        fetchTagPostsTrigger
            .do(onNext: { [unowned self] tag in
                self.searchBarTitle.value = tag // TODO: 検索設定追加
            })
            .flatMap { tag in
                Article.fetch(with: tag)
            }
            .observeOn(Dependencies.sharedInstance.mainScheduler)
            .subscribe(
                onNext: { [weak self] (articles: [Article]) in
                    guard let `self` = self else { return }
                    dump(articles)
                    self.fetchNotification.onNext(articles)
                },
                onError: { (error) in
                    print("error")
            },
                onCompleted: {
                    print("Completed")
            })
            .addDisposableTo(bag)
    }

}
