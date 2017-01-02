//
//  ArticleTableViewCell.swift
//  qiitareader
//
//  Created by hirothings on 2016/10/23.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import UIKit
import RxSwift

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var readLaterButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    
    let checkReadLater = PublishSubject<IndexPath>()
        
    var article: Article! {
        didSet {
            self.titleLabel.text = article.title
            self.detailLabel.text = article.tags.first! // TODO: 複数タグを表示
            let url = URL(string: article.profile_image_url)
            self.profileImageView.sd_setImage(with: url)
        }
    }
    
    private var swipeLocation: CGPoint = CGPoint()
    private var swipeIndexPath: IndexPath = IndexPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let swipeRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.onRightSwipe(_:)))
        swipeRecognizer.delegate = self
        self.cardView.addGestureRecognizer(swipeRecognizer)
    }
    
    
    func onRightSwipe(_ gesture: UIPanGestureRecognizer) {
        self.contentView.backgroundColor = UIColor.green
        let translation = gesture.translation(in: self)
        guard let tableView = self.superview?.superview as? UITableView else { return }


        switch gesture.state {
        case .began:
            print("began")
            swipeLocation = gesture.location(in: tableView)
            swipeIndexPath = tableView.indexPathForRow(at: swipeLocation)!
        case .changed:
            print("changed")
            if 0 < translation.x {
                self.cardView.frame.origin.x = translation.x
            }
        case .ended:
            print("ended")
            if 100 < translation.x {
                checkReadLater.onNext(swipeIndexPath)
            }
            UIView.animate(withDuration: 0.1, animations: { [weak self] in
                self?.cardView.frame.origin.x = 0
            })
        default:
            break
        }

    }
}
