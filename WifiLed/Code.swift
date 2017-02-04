//
//  Code.swift
//  WifiLed
//
//  Created by Gooduo on 17/1/19.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation

struct Code :Hashable {
    let dataArray:[UInt8]
    init(_ array:[UInt8]){
        self.dataArray=array
    }
    var hashValue: Int{
        get {
            return String(describing:self.dataArray).hashValue
        }
    }
    var TypeValue: Int{
        get {
            let val=Array(dataArray[3...4])
            if 0x03==dataArray[3]{
                let val1=Array(dataArray[3 ... 4])+Array(dataArray[6 ... 7])
                return Int(String(describing: val1))!
            }
            return Int(String(describing:val))!
        }
    }
    

}


private typealias temp = Code
extension Hashable {
    public static func ==(l:Self,r:Self) ->Bool {
        return l.hashValue==r.hashValue
    }
}
