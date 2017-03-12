//
//  JSONDecodable.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/26.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

protocol JSONDecodable {
    init(json: [Any], nextPage: String?) // TODO: エラー処理
}
