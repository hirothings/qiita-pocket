//
//  QiitaAPIError.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/20.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

struct QiitaAPIError: Error {
    
    var message: String = ""
    
    
    init?(json: Any) {
        guard let dict = json as? [String: Any] else {
            return nil
        }
        
        guard let originMessage = dict["error"] as? String else {
            return nil
        }
        
        switch originMessage {
        case "Rate limit exceeded.":
            message = "Qiita APIのRateLimitに達しました。しばらく経ってからご利用ください"
        default:
            message = "APIエラーが発生しました"
        }
    }
}
