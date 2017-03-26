//
//  SwipeCellType.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/04.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit

protocol SwipeCellDelegate: class {
    func didSwipeCell(at indexPath: IndexPath)
}

protocol SwipeCellType: class {
    weak var articleView: ArticleView! { get }
    weak var delegate: SwipeCellDelegate? { get }
    var swipeGesture: UIPanGestureRecognizer { get }
    var swipeIndexPath: IndexPath! { get set }
    var isSwiping: Bool { get set }
    func onRightSwipe(_ gesture: UIPanGestureRecognizer)
}

extension SwipeCellType where Self: UITableViewCell {
    
    func onRightSwipe(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        guard let tableView = self.superview?.superview as? UITableView else { return }
        
        switch gesture.state {
        case .began:
            let swipeLocation: CGPoint = gesture.location(in: tableView)
            swipeIndexPath = tableView.indexPathForRow(at: swipeLocation)!
            
        case .changed:
            // 左端より先にはスワイプさせない
            if translation.x < 0 { return }
            
            // スワイプ中、cellを移動させる
            if isSwiping == true {
                self.articleView.frame.origin.x = translation.x
                return
            }
            
            // Y軸へのトランジションが閾値以内の場合、セルを右スワイプ中とみなす
            if abs(translation.y) < 10 {
                isSwiping = true
                tableView.panGestureRecognizer.isEnabled = false // 右スワイプ中はtableviewのscrollを切る
            }
            
        case .ended:
            if 80.0 < translation.x {
                UIView.animate(
                    withDuration: 0.1,
                    animations: { [unowned self] in
                        self.articleView.frame.origin.x = UIScreen.main.bounds.width
                    },
                    completion: { [unowned self] _ in
                        self.delegate?.didSwipeCell(at: self.swipeIndexPath)
                })
            }
            else {
                UIView.animate(withDuration: 0.1, animations: { [unowned self] in
                    self.articleView.frame.origin.x = 0
                })
            }
            tableView.panGestureRecognizer.isEnabled = true // tableviewのscrollを復帰する
            isSwiping = false
        default:
            break
        }
        
    }
}
