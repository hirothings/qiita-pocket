//
//  QiitaClientError.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/07/10.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

enum QiitaClientError: Error {
    case connectionError(ConnectionError)
    case apiError(QiitaAPIError)
}
