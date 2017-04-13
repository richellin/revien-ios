//
//  Sentence.swift
//  ios
//
//  Created by sangjun_lee on 2017/04/12.
//  Copyright © 2017年 Apple Inc. All rights reserved.
//
import RealmSwift

class Sentence: Object {
    dynamic var ko = ""
    dynamic var en = ""
    
    func toString() -> String{
        return "Sentence{ko='\(ko)', en='\(en)'}"
    }
    
    func revers(){
        let tmp = ko
        ko = en
        en = tmp
    }
}
