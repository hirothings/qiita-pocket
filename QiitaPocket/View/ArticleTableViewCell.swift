//
//  ArticleTableViewCell.swift
//  qiitareader
//
//  Created by 坂本 浩 on 2016/10/23.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var readLaterButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setCell(article: Article) {
        self.titleLabel.text = article.title
        self.detailLabel.text = article.tags.first! // TODO: 複数タグを表示
        
        let url = URL(string: article.profile_image_url)
        self.profileImageView.sd_setImage(with: url)
    }
}
