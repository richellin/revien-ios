//
//  Daily.swift
//  ios
//
//  Created by sangjun_lee on 2017/04/12.
//  Copyright © 2017年 Apple Inc. All rights reserved.
//
import RealmSwift

class Daily: Object {
    dynamic var date = 0
    
    override static func primaryKey() -> String? {
        return "date"
    }
    
    let sentences = List<Sentence>()
}
