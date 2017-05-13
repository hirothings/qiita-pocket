//
//  FetchArticleType.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/05/13.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation
import RxSwift

protocol FetchArticleType {
    var articles: Variable<[Article]> { get }
    var searchBarTitle: Variable<String> { get }
    var isLoading: Variable<Bool> { get }
    var hasData: Variable<Bool> { get }
    var scrollViewDidReachedBottom: PublishSubject<Void> { get }
}
