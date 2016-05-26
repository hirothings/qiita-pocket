//
//  APIClient.swift
//  qiitareader
//
//  Created by 坂本 浩 on 2016/05/04.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIClient: NSObject {
    
    static func apiRequest(apiResponse: (responseArticles: [[String: String?]]) -> ()) {
        
        var articles: [[String: String?]] = []
        
        Alamofire.request(.GET, "https://qiita.com/api/v2/items")
            .responseJSON { response in
                
            guard let object = response.result.value else {
                return
            }
            
            let json = JSON(object)
            var article: [String: String?] = [:]
            
            json.forEach { (_, json) in
                                
                article = [
                    "title": json["title"].string,
                    "user": json["user"]["id"].string,
                    "profile_image_url": json["user"]["profile_image_url"].string,
                    "url": json["url"].string,
                ]
                articles.append(article)
            }
                // 自作complete delegate を使ってもOK
            
            apiResponse(responseArticles: articles)
        }
    }
}
