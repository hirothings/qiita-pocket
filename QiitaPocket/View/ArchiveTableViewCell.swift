//
//  ArchiveTableViewCell.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/13.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import WebImage
import RxSwift

final class ArchiveTableViewCell: UITableViewCell, ArticleCellType {
    
    @IBOutlet weak var articleView: ArticleView!
    
    weak var delegate: ArticleCellDelegate?
    private var recycleBag = DisposeBag()
    
    
    var article: Article! {
        didSet {
            configureCell(article: article)
            articleView.dateLabel.text = "\(article.formattedUpdatedAt) 保存"
            articleView.actionButton.rx.tap
                .bindNext { [weak self] in
                    guard let `self` = self else { return }
                    
                    self.articleView.actionButton.isSelected = true
                    self.delegate?.didTapActionButton(on: self)
                }
                .addDisposableTo(recycleBag)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        recycleBag = DisposeBag()
        self.articleView.actionButton.isSelected = false
    }
}
