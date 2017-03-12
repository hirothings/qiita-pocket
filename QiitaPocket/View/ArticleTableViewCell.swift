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

final class ArticleTableViewCell: UITableViewCell, SwipeCellType {
    
    @IBOutlet weak var articleView: ArticleView!
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
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
