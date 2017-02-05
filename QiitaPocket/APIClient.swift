//
//  APIClient.swift
//  qiitareader
//
//  Created by hirothings on 2016/05/04.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

class APIClient {
    
    // MARK: - Properties
    
    private let baseUrl = "https://qiita.com/api/v2"
    
    static let instance = APIClient()
    private let manager = SessionManager()

    private init() {}

    /// Observable化したAPIレスポンスを返す
    func call(mehod: Alamofire.HTTPMethod = .get, path: String) -> Observable<Any> {
        return Observable.create { [unowned self] (observer) -> Disposable in

            self.manager.request(self.buildPath(path))
                .responseJSON { response in
                    
                    // TODO: if DEBUG
                    debugPrint(response)
                    
                    switch response.result {
                    case .success(let value):
                        observer.on(.next(value))
                        observer.on(.completed)
                    case .failure(let error):
                        observer.on(.error(error))
                    }
                }
            return Disposables.create()
        }
    }
    
    /// "/"が先頭にある場合、それ以降の文字列を取得
    private func buildPath(_ path: String) -> URL {
        let trimmedPath = path.hasPrefix("/") ? path.substring(to: path.characters.index(after: path.startIndex)) : path
        return URL(string: baseUrl + "/" + trimmedPath)!
    }
}
