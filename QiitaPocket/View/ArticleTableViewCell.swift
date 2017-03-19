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

final class ArticleTableViewCell: UITableViewCell, SwipeCellType {
    
    @IBOutlet weak var articleView: ArticleView!
    @IBOutlet weak var readLaterIcon: UIImageView!
    var swipeGesture = UIPanGestureRecognizer()
    var swipeIndexPath: IndexPath!
    var preTransration: CGPoint?
    
    weak var delegate: SwipeCellDelegate?
    private var recycleBag = DisposeBag()
    
    var article: Article! {
        didSet {
            articleView.dateLabel.text = "\(article.publishedAt) 投稿"
            articleView.titleLabel.text = article.title
            articleView.tagLabel.text = article.tags.first?.name // TODO: 複数件表示
            articleView.authorID.text = article.author
            let url = URL(string: article.profile_image_url)
            articleView.profileImageView.sd_setImage(with: url)
            articleView.stockCount.text = "\(article.stockCount)"
            swipeGesture.rx.event.bindNext { [weak self] (gesture: UIPanGestureRecognizer) in
                self?.onRightSwipe(gesture)
            }
            .addDisposableTo(recycleBag)

            articleView.articleSaveState = article.saveStateType
            articleView.actionButton.rx.tap
                .bindNext { [weak self] in
                    guard let `self` = self else { return }
                    guard let tableView = self.superview?.superview as? UITableView else { return }
                    guard let indexPath = tableView.indexPath(for: self) else { return }
                    
                    self.articleView.actionButton.isSelected = true
                    self.delegate?.didSwipeCell(at: indexPath)
                }
                .addDisposableTo(recycleBag)
            
            if let rank = article.rank.value {
                articleView.rankLabel.text = "\(rank)"
                articleView.dateLabelLeftConstraint.constant = 20.0
            }
            else {
                articleView.rankLabel.text = nil
                articleView.dateLabelLeftConstraint.constant = 5.0
            }
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
