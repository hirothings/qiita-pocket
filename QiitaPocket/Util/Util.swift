//
//  Util.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/01/29.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

class Util {
    
    static func setDisplayDate(str: String, format: String) -> String {
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        guard let date = inFormatter.date(from: str) else {
            return ""
        }
        
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = format
        return outFormatter.string(from: date)
    }
}
