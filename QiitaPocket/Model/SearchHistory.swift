//
//  SearchHistory.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/20.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

struct SearchHistory {
    
    var tags: [String] {
      return UserSettings.getSearchHistory()
    }
    
    private let max = 10
    
    init() {}
    
    
    func add(tag: String) {
        if tag.isEmpty { return }
        
        var tags = self.tags
        if let _ = tags.index(of: tag) { return } // 重複して登録させない

        tags.insert(tag, at: 0)
        
        if tags.count > max {
            tags.removeLast()
        }
        UserSettings.setSearchHistory(tags: tags)
    }
    
    func delete(index: Int) {
        var tags = self.tags
        tags.remove(at: index)
        UserSettings.setSearchHistory(tags: tags)
    }
}
