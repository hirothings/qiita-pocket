//
//  ArchiveTableViewCell.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/13.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import WebImage
import RxSwift

final class ArchiveTableViewCell: UITableViewCell, ArticleCellType {
    
    @IBOutlet weak var articleView: ArticleView!
    
    var swipeGesture = UIPanGestureRecognizer()
    var preTransration: CGPoint?
    
    weak var delegate: SwipeCellDelegate?
    private var recycleBag = DisposeBag()
    
    
    var article: Article! {
        didSet {
            configureCell(article: article)
            articleView.dateLabel.text = "\(article.formattedUpdatedAt) 保存"
        }
    }
}
