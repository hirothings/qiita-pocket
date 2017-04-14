//
//  ArrayExtension.swift
//  QiitaPocket
//
//  Created by hirothings on 2017/02/26.
//  Copyright © 2017年 hirothings. All rights reserved.
//

import Foundation

extension Array {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}

extension Collection where Indices.Iterator.Element == Index {
    
    subscript(safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
