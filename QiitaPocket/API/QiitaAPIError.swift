//
//  QiitaAPIError.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/20.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

struct QiitaAPIError: Error {
    
    init?(json: Any) {
        guard let dict = json as? [String: Any] else {
            return nil
        }
        
        guard let _ = dict["error"] as? String else {
            return nil
        }
    }
}
