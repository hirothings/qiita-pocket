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
    
    init(json: [Any]) {
        items = json.map { res in
            let json = JSON(res)
            let article = Article()
            
            let createdAt = json["created_at"].stringValue
            article.createdAt = Util.convertDate(str: createdAt, format: "yyyy.MM.dd HH:mm:ss")
            article.id = json["id"].stringValue
            article.title = json["title"].stringValue
            article.user = json["user"]["id"].stringValue
            article.profile_image_url = json["user"]["profile_image_url"].stringValue
            article.url = json["url"].stringValue
            
            let tags = json["tags"].arrayValue
                .map { $0["name"].stringValue }
                .flatMap { Tag(value: $0) }
            
            for tag in tags {
                article.tags.append(tag) // imutableだからappendしかない？
            }
            
            return article
        }
    }


    // TODO: Query付きのリクエストを発行
    static func fetch(with tag: String) -> Observable<Articles>  {
        var path = "items"
        if tag != "" {
            let query = "tag:\(tag)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            path = path + "?" + "query=" + query
        }
        print("path: \(path)")
        return self.apiClient.call(path: path)
    }
}
