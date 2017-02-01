//
//  Article.swift
//  qiitareader
//
//  Created by hirothings on 2016/07/18.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import SwiftyJSON

final class Article: Object {

    dynamic var createdAt: String = ""
    dynamic var id: String = ""
    dynamic var title: String = ""
    dynamic var user: String = ""
    dynamic var profile_image_url: String = ""
    dynamic var url: String = ""
    let tags: List<Tag> = List<Tag>()
    
    override class func primaryKey() -> String? {
        return "id"
    }
}


final class Tag: Object {
    dynamic var name: String = ""
    
    override convenience init(value: Any) {
        self.init()
        self.name = value as! String
    }
}


extension Article {
    
    static let apiClient = APIClient.sharedInstance

    static func fetch() -> Observable<[Article]> {
        return self.apiClient.request(path: "items")
            .observeOn(Dependencies.sharedInstance.backgroundScheduler)
            .map { response in
                guard let response = response as? [AnyObject] else { fatalError("Cast failed") }
                return self.parseJson(response)
            }
            .observeOn(Dependencies.sharedInstance.mainScheduler)
    }
    
    static func parseJson(_ response: [AnyObject]) -> [Article] {
        return response.map { result in
            let json = JSON(result)
            let article = Article()
            
            dump(json)
            
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
}
