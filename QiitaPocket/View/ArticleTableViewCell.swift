//
//  ArticleTableViewCell.swift
//  qiitareader
//
//  Created by hirothings on 2016/10/23.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import UIKit
import RxSwift

protocol SwipeCellDelegate: class {
    func didSwipeReadLater(at indexPath: IndexPath)
}

class ArticleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var readLaterButton: UIButton!
    @IBOutlet weak var cardView: UIView!
    
    var swipeGesture = UIPanGestureRecognizer()
    
    weak var delegate: SwipeCellDelegate?
        
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
        
        swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onRightSwipe(_:)))
        swipeGesture.delegate = self
        self.cardView.addGestureRecognizer(swipeGesture)
    }
    
    
    func onRightSwipe(_ gesture: UIPanGestureRecognizer) {
        self.contentView.backgroundColor = UIColor.green
        let translation = gesture.translation(in: self)
        print("x: \(fabs(gesture.velocity(in: self).x))")
        print("y: \(fabs(gesture.velocity(in: self).y))")
        print(translation.x)
        print(translation.y)

        guard let tableView = self.superview?.superview as? UITableView else { return }
        tableView.panGestureRecognizer.isEnabled = true // tableviewのscrollを復帰する

        // 縦スクロール時は、横スワイプ感知せずreturn
        let verticalGesture = fabs(gesture.velocity(in: self).y) > fabs(gesture.velocity(in: self).x) + 200
        if verticalGesture {
            print("vertical gesture")
            return
        }
        
        switch gesture.state {
        case .began:
            print("swipe began")
            swipeLocation = gesture.location(in: tableView)
            swipeIndexPath = tableView.indexPathForRow(at: swipeLocation)!
        case .changed:
            if 20.0 < translation.x { // 右スワイプ20pt以上を感知する
                tableView.panGestureRecognizer.isEnabled = false // 右スワイプ中はtableviewのscrollを切る
                self.cardView.frame.origin.x = translation.x
            }
        case .ended:
            if 100 < translation.x {
                self.delegate?.didSwipeReadLater(at: swipeIndexPath)
            }
            UIView.animate(withDuration: 0.1, animations: { [weak self] in
                self?.cardView.frame.origin.x = 0
            })
        default:
            break
        }

    }
    
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
