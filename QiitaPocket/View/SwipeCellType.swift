//
//  SwipeCellType.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/04.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit

protocol SwipeCellDelegate: class {
    func isSwipingCell(isSwiping: Bool)
    func didSwipe(cell: UITableViewCell)
}

protocol SwipeCellType: class {
    weak var articleView: ArticleView! { get }
    weak var delegate: SwipeCellDelegate? { get }
    var swipeGesture: UIPanGestureRecognizer { get }
    var swipeIndexPath: IndexPath { get set }
    var isSwiping: Bool { get set }
    func onRightSwipe(_ gesture: UIPanGestureRecognizer, iconView: UIImageView)
}

extension SwipeCellType where Self: UITableViewCell {
    
    func onRightSwipe(_ gesture: UIPanGestureRecognizer, iconView: UIImageView) {
        let translation = gesture.translation(in: self)
        let swipeThreshold: CGFloat = UIScreen.main.bounds.width * 0.35
        
        switch gesture.state {
        case .began:
            break
        case .changed:
            // 左端より先にはスワイプさせない
            if translation.x < 0 { return }
            
            // スワイプ中、cellを移動させる
            if isSwiping == true {
                self.articleView.frame.origin.x = translation.x
                // アイコンの拡大・縮小
                let ratio = translation.x / swipeThreshold
                if 1.0 < ratio { return }
                iconView.alpha = ratio
                iconView.transform = CGAffineTransform(scaleX: ratio, y: ratio)
                return
            }
            
            // Y軸へのトランジションが閾値以内の場合、セルを右スワイプ中とみなす
            if abs(translation.y) < 5 && translation.y < translation.x {
                isSwiping = true
                self.delegate?.isSwipingCell(isSwiping: isSwiping)
            }
            
        case .ended:
            if (swipeThreshold) < translation.x {
                UIView.animate(
                    withDuration: 0.1,
                    animations: { [unowned self] in
                        self.articleView.frame.origin.x = UIScreen.main.bounds.width
                    },
                    completion: { [unowned self] _ in
                        self.delegate?.didSwipe(cell: self)
                })
            }
            else {
                UIView.animate(withDuration: 0.1, animations: { [unowned self] in
                    self.articleView.frame.origin.x = 0
                })
            }
            isSwiping = false
            self.delegate?.isSwipingCell(isSwiping: isSwiping)
        default:
            break
        }
        
    }
}
