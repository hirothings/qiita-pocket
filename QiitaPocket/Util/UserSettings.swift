//
//  UserSettings.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/02.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

// TODO: Protocol + Structにする
class UserSettings {
    
    // 検索キーワード
    static func getcurrentTag() -> String {
        UserDefaults.standard.register(defaults: ["CurrentsearchTag": ""])
        return UserDefaults.standard.string(forKey: "CurrentsearchTag")!
    }
    static func setcurrentTag(name: String) {
        UserDefaults.standard.set(name, forKey: "CurrentsearchTag")
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
    
    // 検索期間
    static func getSearchPeriod() -> SearchPeriod {
        UserDefaults.standard.register(defaults: ["SearchPeriod": SearchPeriod.week.rawValue])
        guard
            let rawvalue = UserDefaults.standard.string(forKey: "SearchPeriod"),
            let searchPeriod = SearchPeriod(rawValue: rawvalue)
        else {
            return SearchPeriod.week
        }
        return searchPeriod
    }
    static func setSearchPeriod(_ searchPeriod: SearchPeriod) {
        UserDefaults.standard.set(searchPeriod.rawValue, forKey: "SearchPeriod")
    }
    
    // delete
    static func delete(for key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
