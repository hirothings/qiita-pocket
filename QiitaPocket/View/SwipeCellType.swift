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
    var preTransration: CGPoint? { get set }
    var indexPath: IndexPath? { get }
    func onRightSwipe(_ gesture: UIPanGestureRecognizer)
}

extension SwipeCellType where Self: UITableViewCell {
    
    func onRightSwipe(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        guard let tableView = self.superview?.superview as? UITableView else { return }
        
        switch gesture.state {
        case .began:
            break
            
        case .changed:
            // 左端より先にはスワイプさせない
            if translation.x < 0 { return }
            
            // トランジション方向が、-x方向の場合、閾値を考慮せずカードを移動させる
            if let preTransration = preTransration {
                if translation.x < preTransration.x {
                    self.articleView.frame.origin.x = translation.x
                }
            }
            
            // トランジション方向が閾値を超えた場合、セルを右スワイプ中とみなす
            if 30.0 < translation.x {
                preTransration = translation
                self.articleView.frame.origin.x = translation.x
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
                        guard let indexPath = self.indexPath else { return }
                        self.delegate?.didSwipeCell(at: indexPath)
                })
            }
            else {
                UIView.animate(withDuration: 0.1, animations: { [unowned self] in
                    self.articleView.frame.origin.x = 0
                })
            }
            tableView.panGestureRecognizer.isEnabled = true // tableviewのscrollを復帰する
            preTransration = nil
        default:
            break
        }
        
    }
}
