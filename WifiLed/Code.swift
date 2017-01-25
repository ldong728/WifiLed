//
//  Code.swift
//  WifiLed
//
//  Created by Gooduo on 17/1/19.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation

class Code :Hashable {
    let dataArray:[UInt8]
    init(_ array:[UInt8]){
        self.dataArray=array
    }
    var hashValue: Int{
        get {
            return String(describing:self.dataArray).hashValue
        }
    }
    

}


private typealias temp = Code
extension Hashable {
    public static func ==(l:Self,r:Self) ->Bool {
        return l.hashValue==r.hashValue
    }
}
