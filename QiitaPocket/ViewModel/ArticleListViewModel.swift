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
    private let bag = DisposeBag()
    
    init() {
        
        fetchTrigger
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
                        self.setStocks(articls: articles)
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

    func setStocks(articls: [Article]) {
        
        for (i, article) in articls.enumerated() {
            Stocks.fetch(with: article.id)
                .subscribe(
                    onNext: { [weak self] (stocks: Stocks) in
                        article.stockCount.value = stocks.count
                        if i == articls.count - 1 {
                            self?.fetchSucceed.onNext(articls)
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
    }
}
