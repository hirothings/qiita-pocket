//
//  ArticleFactory.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/05/13.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation
import RxSwift

class ArticleFactory {
    
    let viewModel: FetchArticleType
    
    init(fetchTrigger: PublishSubject<String>) {
        let searchType = UserSettings.getSearchType()
        switch searchType {
        case .rank:
            self.viewModel = ArticleListViewModel(fetchTrigger: fetchTrigger)
        case .recent:
            self.viewModel = RecentArticleViewModel(fetchTrigger: fetchTrigger)
        }
    }
}
