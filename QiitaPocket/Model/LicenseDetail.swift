//
//  LicenseDetail.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/07/17.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

struct LicenseDetail {
    
    var text: String = ""
    
    init?(title: String) {
        guard let dict: [String : Any] = parsePlist(title) else {
            return nil
        }
        guard let arr = dict["PreferenceSpecifiers"] as? [[String: String]] else {
            return nil
        }
        guard let text = arr.first?["FooterText"] else {
            return nil
        }
        
        self.text = text
    }
    
    private func parsePlist(_ fileName: String) -> [String: Any]? {
        guard let filePath: URL = Bundle.main.url(forResource: fileName, withExtension: "plist") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: filePath)
            return try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        }
        catch {
            return nil
        }
    }
}
