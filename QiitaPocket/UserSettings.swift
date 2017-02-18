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
    static func setSearchHistory(list: [String]) {
        UserDefaults.standard.set(list, forKey: "SearchHistory")
        UserDefaults.standard.synchronize()
    }
    
    // 検索順
    static func getSearchSort() -> SearchSort? {
        guard let rawValue = UserDefaults.standard.string(forKey: "SearchSort") else {
            return nil
        }
        return SearchSort(rawValue: rawValue)
    }
    static func setSearchSort(_ searchSort: SearchSort) {
        UserDefaults.standard.set(searchSort.rawValue, forKey: "SearchSort")
        UserDefaults.standard.object(forKey: "SearchSort")
    }
    
    // 期間
    static func getSearchPeriod() -> SearchPeriod? {
        guard let rawValue = UserDefaults.standard.string(forKey: "SearchPeriod") else {
            return nil
        }
        return SearchPeriod(rawValue: rawValue)
    }
    static func setSearchPeriod(_ searchPeriod: SearchPeriod) {
        UserDefaults.standard.set(searchPeriod.rawValue, forKey: "SearchPeriod")
        UserDefaults.standard.object(forKey: "SearchPeriod")
    }
    
    // delete
    static func delete(for key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
