//
//  Article.swift
//  qiitareader
//
//  Created by 坂本 浩 on 2016/07/18.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

class Article {
    
    
    // MARK: - Properties
    
    let title: String
    let user: String
    let profile_image_url: String
    let url: String
    
    static let apiClient = APIClient.sharedInstance
    
    
    // MARK: - Initializers
    
    init(title: String, user: String, profile_image_url: String, url: String) {
        self.title = title
        self.user = user
        self.profile_image_url = profile_image_url
        self.url = url
    }
    
    
    // MARK: - Static methods
    
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
            let title = json["title"].stringValue
            let user = json["user"]["id"].stringValue
            let profile_image_url = json["user"]["profile_image_url"].stringValue
            let url = json["url"].stringValue
            
            let article = Article(title: title, user: user, profile_image_url: profile_image_url, url: url)
            dump(article)
            return article
        }

    }
}
