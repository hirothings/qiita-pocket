//
//  FetchArticleType.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/05/13.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import RxSwift

protocol FetchArticleType {
    var articles: Variable<[Article]> { get }
    var searchBarTitle: Variable<String> { get }
    var isLoading: Variable<Bool> { get }
    var hasData: Variable<Bool> { get }
    var scrollViewDidReachedBottom: PublishSubject<Void> { get }
    func addReadLaterState(_ articles: [Article]) -> [Article]
}

extension FetchArticleType {
    
    /// あとで読むステータスをarticleに付与する
    func addReadLaterState(_ articles: [Article]) -> [Article] {
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
