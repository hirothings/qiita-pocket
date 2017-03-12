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
            return "items"
        }
        
        var parameters: [String: Any]? {
            if tag.isEmpty {
                return nil
            }
            else {
                return ["query": "tag:" + tag]
            }
        }
    }
    
    /// ストック情報のリクエスト
    struct SearchStocks: QiitaRequest {
        
        typealias ResponseObject = Stocks
        
        let itemID: String
        
        var path: String {
            return "items/\(itemID)/stockers"
        }
        
        var parameters: [String : Any]? { return nil }
    }
}
