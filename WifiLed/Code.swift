//
//  Code.swift
//  WifiLed
//
//  Created by Gooduo on 17/1/19.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation

struct Code :Hashable {
    fileprivate let mCode:[UInt8]
    
    init(_ array:[UInt8]){
        self.mCode=array
    }
    var hashValue: Int{
        get {
            return String(describing:self.mCode).hashValue
        }
    }

}


private typealias temp = Code
extension Hashable {
    public static func ==(l:Self,r:Self) ->Bool {
        return l.hashValue==r.hashValue
    }
}
