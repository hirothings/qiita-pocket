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

protocol SwipeCellDelegate: class {
    func didSwipeCell(at indexPath: IndexPath)
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
            self.detailLabel.text = article.tags.first?.name // TODO: 複数件表示
            let url = URL(string: article.profile_image_url)
            self.profileImageView.sd_setImage(with: url)
        }
    }
    
    private var swipeIndexPath: IndexPath = IndexPath()
    private var preTransration: CGPoint?

    
    override func awakeFromNib() {
        super.awakeFromNib()

        swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onRightSwipe(_:)))
        swipeGesture.delegate = self
        self.cardView.addGestureRecognizer(swipeGesture)
    }
    
    // TODO: protocol化
    func onRightSwipe(_ gesture: UIPanGestureRecognizer) {
        self.contentView.backgroundColor = UIColor.theme
        let translation = gesture.translation(in: self)

        guard let tableView = self.superview?.superview as? UITableView else { return }
        
        switch gesture.state {
        case .began:
            let swipeLocation: CGPoint = gesture.location(in: tableView)
            swipeIndexPath = tableView.indexPathForRow(at: swipeLocation)!

        case .changed:
            // 左端より先にはスワイプさせない
            if translation.x < 0 { return }
            
            // トランジション方向が、-x方向の場合、閾値を考慮せずカードを移動させる
            if let preTransration = preTransration {
                if translation.x < preTransration.x {
                    self.cardView.frame.origin.x = translation.x
                }
            }

            // トランジション方向が閾値を超えた場合、セルを右スワイプ中とみなす
            if 30.0 < translation.x {
                preTransration = translation
                self.cardView.frame.origin.x = translation.x
                tableView.panGestureRecognizer.isEnabled = false // 右スワイプ中はtableviewのscrollを切る
            }

        case .ended:
            if 80.0 < translation.x {
                UIView.animate(
                    withDuration: 0.1,
                    animations: { [unowned self] in
                        self.cardView.frame.origin.x = UIScreen.main.bounds.width
                    },
                    completion: { [unowned self] _ in
                        self.delegate?.didSwipeCell(at: self.swipeIndexPath)
                    })
            }
            else {
                UIView.animate(withDuration: 0.1, animations: { [unowned self] in
                    self.cardView.frame.origin.x = 0
                })
            }
            tableView.panGestureRecognizer.isEnabled = true // tableviewのscrollを復帰する
            preTransration = nil
        default:
            break
        }

    }
    
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
