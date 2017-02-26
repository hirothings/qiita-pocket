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
    
    /// Observable化したAPIレスポンスを返す
    func call<Request: QiitaRequest>(request: Request) -> Observable<Request.ResponseObject> {
        
        return Observable.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create {} }
            
            let url = self.buildPath(baseURL: request.baseURL, path: request.path)
            
            let request = Alamofire.request(url, method: request.method, parameters: request.parameters)
                .responseJSON { response in
                    
                     debugPrint(response)
                    
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [Any] {
                            let responseObject = Request.ResponseObject(json: json)
                            observer.on(.next(responseObject))
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
    private func buildPath(baseURL: String, path: String) -> URL {
        let trimmedPath = path.hasPrefix("/") ? path.substring(to: path.characters.index(after: path.startIndex)) : path
        return URL(string: baseURL + "/" + trimmedPath)!
    }
}
