//
//  Article.swift
//  qiitareader
//
//  Created by hirothings on 2016/07/18.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift
import SwiftyJSON

enum SaveState: String {
    case none
    case readLater
    case archive
}

final class Article: Object {

    dynamic var updatedAt: Date = Date()
    dynamic var publishedAt: String = ""
    dynamic var id: String = ""
    dynamic var title: String = ""
    dynamic var user: String = ""
    dynamic var profile_image_url: String = ""
    dynamic var url: String = ""
    dynamic var saveState: String = SaveState.none.rawValue
    let tags: List<Tag> = List<Tag>()
    dynamic var stockCount: Int = 0
    
    var saveStateType: SaveState {
        get {
            return SaveState(rawValue: saveState)!
        }
        set {
            saveState = newValue.rawValue
        }
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}


final class Tag: Object {
    dynamic var name: String = ""
    
    override convenience init(value: Any) {
        self.init()
        self.name = value as! String
    }
}
