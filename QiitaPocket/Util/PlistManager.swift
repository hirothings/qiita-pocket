//
//  PlistManager.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/12.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

struct PlistManager {
    
    enum FileName: String {
        case Keys
        case licenses
    }
    
    static var testToken: String? {
        guard let keys = getFileContents(PlistManager.FileName.Keys) else {
            return nil
        }
        return keys["TestToken"] as? String
    }
    
    static func getFileContents(_ fileName: FileName) -> [String: Any]? {
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
    
//    static func getLicenseText(licenseName: String) -> String? {
//        guard let licenses = getFileContents(KeyManager.FileName.Keys) else {
//            return nil
//        }
//        guard let licenseText = licenses[licenseName]
//    }
}
