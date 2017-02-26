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

final class Article: Object {

    dynamic var createdAt: String = ""
    dynamic var id: String = ""
    dynamic var title: String = ""
    dynamic var user: String = ""
    dynamic var profile_image_url: String = ""
    dynamic var url: String = ""
    let tags: List<Tag> = List<Tag>()
    
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


extension Article {

}
