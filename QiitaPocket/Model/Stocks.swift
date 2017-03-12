//
//  Stocks.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/12.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

struct Stocks: JSONDecodable {
    
    static let apiClient = APIClient()
    let count: Int
    
    init(json: [Any]) {
        count = json.count
    }
    
    static func fetch(with itemID: String) -> Observable<Stocks> {
        let request = QiitaAPI.SearchStocks(itemID: itemID)
        return self.apiClient.call(request: request)
    }
}
