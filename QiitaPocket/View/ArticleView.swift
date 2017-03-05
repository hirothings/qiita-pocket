//
//  ArticleView.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/04.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit

@IBDesignable
class ArticleView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var authorID: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var likeCount: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initview()
    }

    private func initview() {
        Bundle.main.loadNibNamed("ArticleView", owner: self, options: nil)
        bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 103.0)
        contentView.frame = bounds
        addSubview(contentView)
    }
}
