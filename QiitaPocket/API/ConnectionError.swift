//
//  ConnectionError.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/03/20.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

struct ConnectionError: Error {
    var message: String
    
    init(errorCode: Int) {
        
        switch errorCode {
        case -1001:
            message = "通信がタイムアウトしました。通信環境の良い場所で再度お試しください"
        case -1009:
            message = "ネットワークに接続されていません"
        default:
            message = "通信エラーが発生しました"
        }
    }
}
