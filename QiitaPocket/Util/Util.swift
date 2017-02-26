//
//  Util.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/01/29.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

class Util {
    
    static func convertDate(str: String, format: String) -> String {
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let date = inFormatter.date(from: str)!
        
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = format
        return outFormatter.string(from: date)
    }
}
