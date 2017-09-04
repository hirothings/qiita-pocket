//
//  QiitaRequest.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/26.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation
import Alamofire

protocol QiitaRequest {
    associatedtype ResponseObject: JSONDecodable
    
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
}

extension QiitaRequest {
    var method: HTTPMethod {
        return Alamofire.HTTPMethod.get
    }
}
