//
//  Dependencies.swift
//  qiitareader
//
//  Created by hirothings on 2016/07/18.
//  Copyright © 2016年 hiroshings. All rights reserved.
//

import Foundation
import RxSwift

class Dependencies {

    // MARK: - Properties
    
    let mainScheduler: SerialDispatchQueueScheduler = MainScheduler.instance
    let backgroundScheduler: ImmediateSchedulerType = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = QualityOfService.userInitiated
        
        return OperationQueueScheduler(operationQueue: operationQueue)
    }()
    
    static let sharedInstance = Dependencies()
    
    // MARK: - Initializers
    
    fileprivate init() {}
}
