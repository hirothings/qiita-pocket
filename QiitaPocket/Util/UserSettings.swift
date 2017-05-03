//
//  UserSettings.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/02.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

class UserSettings {
    
    // 検索タグ
    static func getCurrentSearchTag() -> String {
        UserDefaults.standard.register(defaults: ["CurrentSearchTag": ""])
        return UserDefaults.standard.string(forKey: "CurrentSearchTag")!
    }
    static func setCurrentSearchTag(name: String) {
        UserDefaults.standard.set(name, forKey: "CurrentSearchTag")
    }
    
    // 検索履歴
    static func getSearchHistory() -> [String] {
        let strArray: [String] = []
        UserDefaults.standard.register(defaults: ["SearchHistory": strArray])
        return UserDefaults.standard.stringArray(forKey: "SearchHistory")!
    }
    static func setSearchHistory(tags: [String]) {
        UserDefaults.standard.set(tags, forKey: "SearchHistory")
        UserDefaults.standard.synchronize()
    }
    
    // 検索タイプ
    static func getSearchType() -> SearchType {
        UserDefaults.standard.register(defaults: ["SearchType": "rank"])
        guard let rawValue = UserDefaults.standard.string(forKey: "SearchType") else {
            return SearchType.rank
        }
        guard let searchType = SearchType(rawValue: rawValue) else {
            return SearchType.rank
        }
        return searchType
    }
    static func setSearchType(_ searchType: SearchType) {
        UserDefaults.standard.set(searchType.rawValue, forKey: "SearchType")
    }
    
    // delete
    static func delete(for key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
