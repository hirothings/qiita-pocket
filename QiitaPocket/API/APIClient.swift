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
    
    
    /// Observable化したAPIレスポンスを返す
    func call<Request: QiitaRequest>(request: Request) -> Observable<Request.ResponseObject> {
        
        return Observable.create { [weak self] observer -> Disposable in
            guard let `self` = self else { return Disposables.create {} }
            
            let url = self.buildPath(baseURL: request.baseURL, path: request.path)

            let request = Alamofire.request(url, method: request.method, parameters: request.parameters, headers: nil)
                .responseJSON { response in
                    
                    var nextPage: Int? = nil
                    let nextPageStr: String? = self.parseNextPage(header: response.response?.allHeaderFields)
                    if let nextPageStr = nextPageStr {
                        nextPage = Int(nextPageStr)
                    }

                    switch response.result {
                    case .success(let value):
                        // QiitaAPIのエラー処理
                        if let qiitaAPIError = QiitaAPIError(json: value) {
                            observer.onError(qiitaAPIError)
                        }
                        if let json = value as? [Any] {
                            let responseObject = Request.ResponseObject(json: json, nextPage: nextPage)
                            observer.on(.next(responseObject))
                        }
                        observer.on(.completed)
                    case .failure(let error):
                        let connectingError = ConnectionError(errorCode: error._code)
                        observer.on(.error(connectingError))
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
    
    /// 次のページ番号をLinkヘッダーからParseする
    private func parseNextPage(header: [AnyHashable: Any]?) -> String? {
        guard let serializedLinks = header?["Link"] as? String else { return nil }
        do {
            let regex = try NSRegularExpression(pattern: "(?<=page=)(.+?)(?=.*rel=\"next\")", options: .allowCommentsAndWhitespace)
            guard let match = regex.firstMatch(in: serializedLinks,
                                               options: NSRegularExpression.MatchingOptions(),
                                               range: NSRange(location: 0, length: serializedLinks.characters.count)) else { return nil }

            let matcheStrings = (1 ..< match.numberOfRanges).map { rangeIndex -> String in
                let range = match.range(at: rangeIndex) // マッチングした位置
                // CharacterView型のindexに変換
                let startIndex: String.CharacterView.Index = serializedLinks.characters.index(serializedLinks.startIndex, offsetBy: range.location)
                let endIndex: String.CharacterView.Index = serializedLinks.characters.index(serializedLinks.startIndex, offsetBy: range.location + range.length)
                let stringRange = startIndex ..< endIndex
                return serializedLinks.substring(with: stringRange) // マッチした文字列を抜き出す
            }
            return matcheStrings.first
        }
        catch {
            return nil
        }
    }
}
