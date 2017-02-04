//
//  CodeType.swift
//  WifiLed
//
//  Created by Gooduo on 17/1/24.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation

struct CodeType : Hashable{
    let dataArray:[UInt8]

    init(_ array:[UInt8]){
        self.dataArray=array
    }
    init(_ code:Code){
        self.dataArray=code.dataArray
    }
    var hashValue: Int{
        get {
            let val=Array(dataArray[3...4])
            if 0x03==dataArray[3]{
                let val1=Array(dataArray[3 ... 4])+Array(dataArray[6 ... 7])
                return String(describing: val1).hashValue
            }
            return String(describing:val).hashValue
        }
    }
    public static func ==(l:CodeType,r:CodeType) ->Bool {
        return l.hashValue==r.hashValue
    }

    
}

