//
//  ReadLaterTableViewCell.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/13.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import WebImage
import RxSwift

final class ReadLaterTableViewCell: UITableViewCell, SwipeCellType, ArticleCellType {

    @IBOutlet weak var checkIconView: UIImageView!
    @IBOutlet weak var articleView: ArticleView!
    
    var swipeGesture = UIPanGestureRecognizer()
    var swipeIndexPath: IndexPath = IndexPath()
    var isSwiping = false
    
    weak var delegate: SwipeCellDelegate?
    private var recycleBag = DisposeBag()
    
    
    var article: Article! {
        didSet {
            configureCell(article: article)
            articleView.dateLabel.text = "\(article.formattedUpdatedAt) 保存"
            
            swipeGesture.rx.event.bindNext { [weak self] (gesture: UIPanGestureRecognizer) in
                    guard let `self` = self else { return }
                    self.onRightSwipe(gesture, iconView: self.checkIconView)
                }
                .addDisposableTo(recycleBag)
            
            articleView.actionButton.rx.tap
                .bindNext { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.articleView.actionButton.isSelected = true
                    self.delegate?.didSwipe(cell: self)
                }
                .addDisposableTo(recycleBag)
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
            self.contentView.backgroundColor = UIColor.readLater
        }
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
