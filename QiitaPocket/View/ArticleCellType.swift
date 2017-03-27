//
//  ArticleCellType.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/27.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit

protocol ArticleCellType: class {
    weak var articleView: ArticleView! { get }
    func configureCell(article: Article)
}

extension ArticleCellType where Self: UITableViewCell {
    func configureCell(article: Article) {
        articleView.titleLabel.text = article.title
        articleView.tagLabel.text = article.tags.first?.name
        articleView.authorID.text = article.author
        let url = URL(string: article.profile_image_url)
        articleView.profileImageView.sd_setImage(with: url)
        articleView.stockCount.text = "\(article.stockCount)"
        articleView.saveState = article.saveStateType
    }
}
