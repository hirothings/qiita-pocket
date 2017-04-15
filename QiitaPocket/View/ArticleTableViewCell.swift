//
//  ArticleTableViewCell.swift
//  qiitareader
//
//  Created by hirothings on 2016/10/23.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import UIKit
import WebImage
import RxSwift
import RxCocoa

final class ArticleTableViewCell: UITableViewCell, SwipeCellType, ArticleCellType {
    
    @IBOutlet weak var articleView: ArticleView!
    @IBOutlet weak var readLaterIcon: UIImageView!
    @IBOutlet weak var readLaterIconView: UIImageView!
    
    var swipeGesture = UIPanGestureRecognizer()
    var swipeIndexPath: IndexPath = IndexPath()
    var isSwiping = false
    
    weak var delegate: SwipeCellDelegate?
    private var recycleBag = DisposeBag()
    
    var article: Article! {
        didSet {
            configureCell(article: article)
            
            articleView.dateLabel.text = "\(article.publishedAt) 投稿"
            swipeGesture.rx.event.bindNext { [weak self] (gesture: UIPanGestureRecognizer) in
                guard let `self` = self else { return }
                self.onRightSwipe(gesture, iconView: self.readLaterIconView)
            }
            .addDisposableTo(recycleBag)

            articleView.actionButton.rx.tap
                .bindNext { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.articleView.actionButton.isSelected = true
                    self.delegate?.didSwipe(cell: self)
                }
                .addDisposableTo(recycleBag)
            
            if let rank = article.rank.value {
                articleView.rankBadgeView.isHidden = false
                articleView.rankLabel.text = "\(rank)"
                switch rank {
                case 1:
                    articleView.rankBGImageView.tintColor = UIColor.rankGold
                case 2:
                    articleView.rankBGImageView.tintColor = UIColor.rankSilver
                case 3:
                    articleView.rankBGImageView.tintColor = UIColor.rankBronse
                default:
                    articleView.rankBGImageView.tintColor = UIColor.disabled
                }
            }
            else {
                articleView.rankBadgeView.isHidden = true
            }
            
            articleView.actionButton.isSelected = article.hasSaved
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        swipeGesture.delegate = self
        self.articleView.addGestureRecognizer(swipeGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        recycleBag = DisposeBag()
        self.articleView.actionButton.isSelected = false
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(true, animated: true)
        if highlighted {
            self.articleView.backgroundColor = UIColor.bg
        }
        else {
            self.articleView.backgroundColor = UIColor.white
            self.contentView.backgroundColor = UIColor.theme
        }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
