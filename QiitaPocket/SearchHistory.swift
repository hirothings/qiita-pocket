//
//  SearchHistory.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/20.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

struct SearchHistory {
    
    var items: [String]
    
    init(history: String, max: Int = 10) {
        self.items = UserSettings.getSearchHistory()
        self.items.insert(history, at: 0)

        if self.items.count > max {
            self.items.removeLast()
        }
    }
}
