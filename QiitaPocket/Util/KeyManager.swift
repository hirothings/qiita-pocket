//
//  KeyManager.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/12.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

struct KeyManager {
    
    static let keyFilePath = Bundle.main.url(forResource: "Keys", withExtension: "plist")
    
    static var testToken: String? {
        guard let keys = getKeys() else {
            return nil
        }
        return keys["TestToken"] as? String
    }
    
    static func getKeys() -> [String: Any]? {
        guard let keyFilePath = keyFilePath else {
            return nil
        }
        do {
            let data = try Data(contentsOf: keyFilePath)
            return try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        }
        catch {
            return nil
        }
    }
}
