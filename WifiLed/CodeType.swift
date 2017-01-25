//
//  CodeType.swift
//  WifiLed
//
//  Created by Gooduo on 17/1/24.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation

class CodeType : Code{

    override init(_ data:[UInt8]){
        super.init(data)
    }
    init(_ code:Code){
        super.init(code.dataArray)
    }
    override var hashValue: Int{
        get {
            let val=Array(dataArray[3...4])
            if 0x03==dataArray[3]{
                let val1=Array(dataArray[3 ... 4])+Array(dataArray[6 ... 7])
                return String(describing: val1).hashValue
            }
            return String(describing:val).hashValue
        }
    }
    
}

