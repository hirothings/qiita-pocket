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
    let fetchNotification = PublishSubject<Void>()
    
    private let bag = DisposeBag()
    
    init() {
        fetchTrigger
            .flatMap {
                Article.fetch()
            }
            .observeOn(Dependencies.sharedInstance.mainScheduler)
            .subscribe(
                onNext: { (response: Any) in
                    let articles = Article.parseJson(object: response)
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
