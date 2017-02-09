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

    /// Observable化したAPIレスポンスを返す
    func call(path: String, mehod: Alamofire.HTTPMethod = .get) -> Observable<[Article]> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create {} }
            let request = Alamofire.request(self.buildPath(path))
                .responseJSON { response in
                    
                    // TODO: if DEBUG
                    // debugPrint(response)
                    
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [Any] {
                            let articles = Article.parseJSON(response: json)
                            observer.on(.next(articles))
                        }
                        observer.on(.completed)
                    case .failure(let error):
                        observer.on(.error(error))
                    }
                }
            
            request.resume()
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    /// "/"が先頭にある場合、それ以降の文字列を取得
    private func buildPath(_ path: String) -> URL {
        let trimmedPath = path.hasPrefix("/") ? path.substring(to: path.characters.index(after: path.startIndex)) : path
        return URL(string: baseUrl + "/" + trimmedPath)!
    }
}
