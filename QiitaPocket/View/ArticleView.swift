//
//  ArticleView.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/04.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit

class ArticleView: UIView {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var authorID: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var stockCount: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var rankBadgeView: UIView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var dateLabelLeftConstraint: NSLayoutConstraint!
    
    var rankBGImageView: UIImageView = {
        let bgImage = #imageLiteral(resourceName: "ic-rank-bg").withRenderingMode(.alwaysTemplate)
        let rankBGImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 53, height: 29))
        rankBGImageView.image = bgImage
        return rankBGImageView
    }()

    var articleSaveState: SaveState = .none {
        willSet(state) {
            switch state {
            case .none:
                self.actionButton.setImage(#imageLiteral(resourceName: "ic-read-later_disabled"), for: .normal)
                self.actionButton.setImage(#imageLiteral(resourceName: "ic-read-later"), for: .selected)
            case .readLater:
                self.actionButton.setImage(#imageLiteral(resourceName: "ic-check_disabled"), for: .normal)
                self.actionButton.setImage(#imageLiteral(resourceName: "ic-check"), for: .selected)
            case .archive:
                self.actionButton.setImage(#imageLiteral(resourceName: "ic-delete"), for: .normal)
                self.actionButton.setImage(#imageLiteral(resourceName: "ic-delete_on"), for: .selected)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initview()
    }

    private func initview() {
        let view = Bundle.main.loadNibNamed("ArticleView", owner: self, options: nil)!.first as! UIView
        addSubview(view)
        
        // profile画像を丸くする
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width * 0.5
        profileImageView.clipsToBounds = true
        
        // 日時の左marginはトルツメしておく
        rankBadgeView.isHidden = true
        dateLabelLeftConstraint.constant = 0.0
        
        // 最背面にランキング画像を置く
        rankBadgeView.addSubview(rankBGImageView)
        rankBadgeView.sendSubview(toBack: rankBGImageView)
        
        // カスタムViewのサイズを自分自身と同じサイズにする
        view.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
    }
}
