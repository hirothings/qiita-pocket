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
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var readLaterButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    
    var swipeGesture = UIPanGestureRecognizer()
    var swipeIndexPath: IndexPath = IndexPath()
    var preTransration: CGPoint?
    
    weak var delegate: SwipeCellDelegate?
    
    var article: Article! {
        didSet {
            self.titleLabel.text = article.title
            self.detailLabel.text = article.tags.first?.name // TODO: 複数件表示
            let url = URL(string: article.profile_image_url)
            self.profileImageView.sd_setImage(with: url)
        }
    }
    
    private var bag = DisposeBag()

    
    override func awakeFromNib() {
        super.awakeFromNib()
        swipeGesture.rx.event.bindNext { [weak self] (gesture: UIPanGestureRecognizer) in
            self?.onRightSwipe(gesture)
        }
        .addDisposableTo(bag)
        swipeGesture.delegate = self
        self.cardView.addGestureRecognizer(swipeGesture)
    }
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
