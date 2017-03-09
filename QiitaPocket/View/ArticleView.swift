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
        let view = Bundle.main.loadNibNamed("ArticleView", owner: self, options: nil)!.first as! UIView
        addSubview(view)
        
        // カスタムViewのサイズを自分自身と同じサイズにする
        view.translatesAutoresizingMaskIntoConstraints = false
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
    }
}
