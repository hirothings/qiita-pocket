//
//  QiitaAPI.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/26.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

final class QiitaAPI {
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
                return ["tag": tag]
            }
        }
    }
}
