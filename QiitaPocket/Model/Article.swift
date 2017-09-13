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

    @objc dynamic var updatedAt: Date = Date()
    @objc dynamic var publishedAt: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var author: String = ""
    @objc dynamic var profile_image_url: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var saveState: String = SaveState.none.rawValue
    @objc dynamic var hasSaved: Bool = false
    let tags: List<Tag> = List<Tag>()
    @objc dynamic var stockCount: Int = 0
    let rank = RealmOptional<Int>()
    
    var saveStateType: SaveState {
        get {
            return SaveState(rawValue: saveState)!
        }
        set {
            saveState = newValue.rawValue
        }
    }
    
    var formattedUpdatedAt: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        return formatter.string(from: updatedAt)
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}


final class Tag: Object {
    @objc dynamic var name: String = ""
    
    override convenience init(value: Any) {
        self.init()
        self.name = value as! String
    }
}
