//
//  ArticleManager.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/01/15.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation
import RealmSwift

final class ArticleManager {
    
    static let realm: Realm = try! Realm()

    /// 全件取得
    static func getAll() -> Results<Article> {
        return realm.objects(Article.self)
    }
    
    /// 追加・更新
    static func update(article: Article) {
        do {
            try realm.write {
                realm.add(article, update: true)
            }
        }
        catch _ {
            // TODO: error処理
        }
    }
    
    /// 削除
    static func delete(article: Article) {
        do {
            try realm.write {
                realm.delete(article)
            }
        }
        catch let _ {
            // TODO: error処理
        }
    }
}
