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

        var path: String {
            return "search"
        }
        
        var parameters: [String: Any]? {
            if tag.isEmpty {
                return nil
            }
            else {
                return ["q": tag]
            }
        }
    }
    
    /// 過去1週間分の記事のリクエスト
    struct SearchWeeklyPost: QiitaRequest {
        
        typealias ResponseObject = Articles
        
        let tag: String
        let page: String
        
        var path: String {
            return "search"
        }
        
        var parameters: [String: Any]? {
            
            let oneWeekAgo: String = {
                let now = Date()
                let oneWeekAgo = Date(timeInterval: -60 * 60 * 24 * 7, since: now)
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter.string(from: oneWeekAgo)
            }()
            
            var params: [String: String] = [
                "page": page,
                "per_page": "100", // 100が上限
            ]
            
            if tag.isEmpty {
                // RateLimit緩和のため、キーワードなしは5件以上はストックされている前提で記事を取得する
                params["q"] = "created:>" + oneWeekAgo + " stocks:" + ">5"
                return params
            }
            else {
                params["q"] = tag + " created:>" + oneWeekAgo + " stocks:" + ">1"
                return params
            }
        }
    }
}
