//
//  QiitaAPI.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/26.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

final class QiitaAPI {
    
    /// 投稿記事のリクエスト
    struct SearchArticles: QiitaRequest {
        typealias ResponseObject = Articles
        
        let tag: String
        let page: Int
        
        // Qiita API v2
        var baseURL: String {
            return "https://qiita.com/api/v2"
        }

        var path: String {
            return "items"
        }
        
        var parameters: [String: Any]? {
            if tag.isEmpty {
                return ["page": page]
            }
            else {
                return ["page": page, "q": tag]
            }
        }
    }
    
    /// ランキング記事のリクエスト
    struct SearchRankedPost: QiitaRequest {
        typealias ResponseObject = Articles
        
        let tag: String
        let period: SearchPeriod
        
        // Qiita Pocket用自作API
        var baseURL: String {
            return "https://qiita-pocket-api.herokuapp.com"
        }
        
        var path: String {
            return "search"
        }
        
        var parameters: [String: Any]? {
            if tag.isEmpty {
                return ["period": period.rawValue]
            }
            else {
                return [
                    "period": period.rawValue,
                    "tag": tag
                ]
            }
        }
    }
}
