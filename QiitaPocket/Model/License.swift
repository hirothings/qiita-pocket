//
//  License.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/12.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

struct License {
    
    var titles: [String] = []
    
    init?() {
        guard let dict: [String : Any] = parsePlist(FileName.licenses) else {
            return nil
        }
        guard let licenses = dict["PreferenceSpecifiers"] as? [[String: String]] else {
            return nil
        }
        titles = licenses.flatMap { $0["Title"] }
    }
    
    
    private func parsePlist(_ fileName: FileName) -> [String: Any]? {
        guard let filePath: URL = Bundle.main.url(forResource: fileName.rawValue, withExtension: "plist") else {
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
