//
//  SearchHistoryTableViewCell.swift
//  QiitaPocket
//
//  Created by PIVOT on 2017/05/02.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol SearchHistoryCellDelegate: class {
    func didTapDeleteBtn(on cell: UITableViewCell)
}


class SearchHistoryTableViewCell: UITableViewCell {
    
    weak var delegate: SearchHistoryCellDelegate?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    private var recycleBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        deleteBtn.rx.tap.bindNext { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.didTapDeleteBtn(on: self)
        }
        .addDisposableTo(recycleBag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        recycleBag = DisposeBag()
    }
}
