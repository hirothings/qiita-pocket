//
//  APIClient.swift
//  qiitareader
//
//  Created by 坂本 浩 on 2016/05/04.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxSwift
import RxCocoa

class APIClient {
    
    
    // MARK: - Properties
    
    let baseUrl = "https://qiita.com/api/v2"
    
    static let sharedInstance = APIClient()
    private let manager = SessionManager()

    private init() {}
    
    
    func request(_ method: Alamofire.HTTPMethod = .get, path: String) -> Observable<Any> {
        if let request = self.manager.request(self.buildPath(path)).request {
            return self.manager.session.rx.json(request: request)
        }
        else {
            fatalError("Invalid request")
        }
    }
    
    /// "/"が先頭にある場合、それ以降の文字列を取得
    func buildPath(_ path: String) -> URL {
        let trimmedPath = path.hasPrefix("/") ? path.substring(to: path.characters.index(after: path.startIndex)) : path
        return URL(string: baseUrl + "/" + trimmedPath)!
    }
}
