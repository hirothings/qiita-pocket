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
    
    /// 後で読むを取得
    static func getReadLaters() -> Results<Article> {
        return realm.objects(Article.self).filter("saveState == '\(SaveState.readLater.rawValue)'").sorted(byKeyPath: "updatedAt", ascending: false)
    }
    
    /// アーカイブを取得
    static func getArchives() -> Results<Article> {
        return realm.objects(Article.self).filter("saveState == '\(SaveState.archive.rawValue)'").sorted(byKeyPath: "updatedAt", ascending: false)
    }
    
    /// 後で読むに追加
    static func add(readLater article: Article) {
        do {
            try realm.write {
                article.saveStateType = .readLater
                article.updatedAt = Date()
                realm.add(article, update: true)
            }
        }
        catch _ {
            // TODO: error処理
        }
    }
    
    /// アーカイブに追加
    static func add(archive article: Article) {
        do {
            try realm.write {
                article.saveStateType = .archive
                article.updatedAt = Date()
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
        catch _ {
            // TODO: error処理
        }
    }
}
