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

// TODO: 共通化
final class ArchiveTableViewCell: UITableViewCell {
    
    @IBOutlet weak var articleView: ArticleView!
    
    var swipeGesture = UIPanGestureRecognizer()
    var swipeIndexPath: IndexPath!
    var preTransration: CGPoint?
    var indexPath: IndexPath?
    
    weak var delegate: SwipeCellDelegate?
    private var recycleBag = DisposeBag()
    
    
    var article: Article! {
        didSet {
            articleView.dateLabel.text = "\(article.formattedUpdatedAt) 保存"
            articleView.titleLabel.text = article.title
            articleView.tagLabel.text = article.tags.first?.name
            articleView.authorID.text = article.author
            let url = URL(string: article.profile_image_url)
            articleView.profileImageView.sd_setImage(with: url)
            articleView.stockCount.text = "\(article.stockCount)"
            articleView.articleSaveState = article.saveStateType
        }
    }
    
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(true, animated: true)
        if highlighted {
            self.articleView.backgroundColor = UIColor.bg
        }
        else {
            self.articleView.backgroundColor = UIColor.white
        }
    }
}
