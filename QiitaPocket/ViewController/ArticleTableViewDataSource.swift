//
//  ArticleTableViewDataSource.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/05/05.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class ArticleTableViewDataSource: NSObject, UITableViewDataSource, RxTableViewDataSourceType, SwipeCellDelegate, UITableViewDelegate {
    
    typealias Element = [Article]
    private var articles: Element = []
    
    let isSwipingCell = PublishSubject<Bool>()
    let didSwipeCell = PublishSubject<UITableViewCell>()
    let didTapTableRow = PublishSubject<IndexPath>()
    
    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        if case .next(let articles) = observedEvent {
            self.articles = articles
            tableView.reloadData()
        }
    }
    
    
    // MARK: - TableView DataSource
    
    /// tableViewの行数を指定
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    /// tableViewのcellを生成
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as! ArticleTableViewCell
        cell.article = articles[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let searchType = UserSettings.getSearchType()
        let currentTag = UserSettings.getCurrentSearchTag()

        var text: String
        switch searchType {
        case .rank:
            text = "週間ランキング"
        case .recent:
            text = "新着順"
        }

        if currentTag.isEmpty {
            text += ": すべて"
        }
        else {
            text += ": \(currentTag)"
        }

        let label: UILabel = {
            let lb = UILabel(frame: CGRect(x: 10.0, y: 0.0, width: UIScreen.main.bounds.width, height: 30.0))
            lb.text = text
            lb.textColor = UIColor.white
            lb.font = UIFont.boldSystemFont(ofSize: 12.0)
            return lb
        }()

        let view: UIView = {
            let v = UIView()
            switch searchType {
            case .rank:
                v.backgroundColor = UIColor.rankGold
            case .recent:
                v.backgroundColor = UIColor.theme
            }
            return v
        }()

        view.addSubview(label)
        return view
    }
    

    // MARK: - SwipeCellDelegate
    
    func isSwipingCell(isSwiping: Bool) {
        isSwipingCell.onNext(isSwiping)
    }
    
    func didSwipe(cell: UITableViewCell) {
        didSwipeCell.onNext(cell)
    }
}
