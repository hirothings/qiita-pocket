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
    case searchLimit
    case searchMode
    case searchTag
    
    // Int
    func set(value: Int) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }
    func get() -> Int {
        return UserDefaults.standard.integer(forKey: self.rawValue)
    }
    
    // Object
    func set(value: Any) {
        UserDefaults.standard.set(value, forKey: self.rawValue)
    }
    func get() -> Any? {
        return UserDefaults.standard.object(forKey: self.rawValue)
    }
    
    // delete
    func delete() {
        UserDefaults.standard.removeObject(forKey: self.rawValue)
    }
}
