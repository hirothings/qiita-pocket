//
//  SearchHistory.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/20.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

struct SearchHistory {
    
    var keywords: [String] {
      return UserSettings.getSearchHistory()
    }
    
    private let max = 10
    
    init() {}
    
    
    func add(keyword: String) {
        if keyword.isEmpty { return }
        
        var keywords = self.keywords
        if let _ = keywords.index(of: keyword) { return } // 重複して登録させない

        keywords.insert(keyword, at: 0)
        
        if keywords.count > max {
            keywords.removeLast()
        }
        UserSettings.setSearchHistory(keywords: keywords)
    }
    
    func delete(index: Int) {
        var keywords = self.keywords
        keywords.remove(at: index)
        UserSettings.setSearchHistory(keywords: keywords)
    }
}
