//
//  UserSettings.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/02.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation


enum UserSettings: String {
    
    case searchHistory
    case searchSort
    case searchPeriod
    case searchTag
    
    // Int
    func set(value: Int) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }
    func integer() -> Int {
        return UserDefaults.standard.integer(forKey: self.rawValue)
    }
    
    // String
    func string() -> String? {
        return UserDefaults.standard.string(forKey: self.rawValue)
    }
    
    // Object
    func set(value: Any) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }
    func object() -> Any? {
        return UserDefaults.standard.object(forKey: self.rawValue)
    }
    
    // delete
    func delete() {
        UserDefaults.standard.removeObject(forKey: self.rawValue)
    }
}
