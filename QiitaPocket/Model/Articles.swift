//
//  Articles.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/26.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

struct Articles: JSONDecodable {
    
    static let apiClient = APIClient()
    let items: [Article]
    let nextPage: Int?
    
    init(json: [Any], nextPage: Int?) {
        items = json.map { res in
            let json = JSON(res)
            let article = Article()
            
            let createdAt = json["created_at"].stringValue
            article.publishedAt = Util.setDisplayDate(str: createdAt, format: "yyyy.MM.dd")
            article.id = json["id"].stringValue
            article.title = json["title"].stringValue
            article.author = json["user"]["url_name"].stringValue
            article.profile_image_url = json["user"]["profile_image_url"].stringValue
            article.url = json["url"].stringValue
            
            let tags = json["tags"].arrayValue
                .map { $0["name"].stringValue }
                .flatMap { Tag(value: $0) }
            
            for tag in tags {
                article.tags.append(tag) // imutableだからappendしかない？
            }
            
            article.stockCount = json["likes_count"].intValue
            
            return article
        }
        
        self.nextPage = nextPage
    }

    static func fetch(with tag: String, page: Int) -> Observable<Articles>  {
        let request = QiitaAPI.SearchArticles(tag: tag, page: page)
        return self.apiClient.call(request: request)
    }
    
    static func fetchRankedPost(with tag: String, period: SearchPeriod) -> Observable<Articles>  {
        let request = QiitaAPI.SearchRankedPost(tag: tag, period: period)
        return self.apiClient.call(request: request)
    }
}
