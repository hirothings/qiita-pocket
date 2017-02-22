//
//  SearchHistory.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/20.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

struct SearchHistory {
    
    static var list: [String] {
      return UserSettings.getSearchHistory()
    }
    
    private let max = 10
    
    init() {}
    
    
    func add(history: String) {
        if history == "" { return }
        
        var list = UserSettings.getSearchHistory()
        list.insert(history, at: 0)
        
        if list.count > max {
            list.removeLast()
        }
        UserSettings.setSearchHistory(list: list)
    }
}
