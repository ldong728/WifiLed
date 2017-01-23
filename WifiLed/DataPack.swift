//
//  DataPack.swift
//  WifiLed
//
//  Created by Gooduo on 17/1/17.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation

class DataPack {
    fileprivate let ip:String
    fileprivate let port:UInt16
    fileprivate var data:[UInt8]
    init(ip:String,port:UInt16,data:[UInt8]){
        self.ip=ip
        self.port=port
        self.data=data
    }
    init(data:Data,address:Data){
        self.data=[UInt8](data)
        self.ip = String(address[4]) + "." + String(address[5]) + "." + String(address[6]) + "." + String(address[7])
        self.port=UInt16(address[2])<<8 + UInt16(address[3])
        
    }
    
    internal func getData() ->[UInt8]{
        return data;
    }
    internal func getIp() ->String{
        return ip
    }
    internal func getPort() ->UInt16{
        return port
    }
    internal func getLength() ->Int {
        return data.count;
    }
    internal func merge(otherData:[UInt8]) ->[UInt8]{
        self.data+=otherData
        return getData()
    }
    internal func merge(otherPack: DataPack) {
        self.data+=otherPack.getData()
    }
    
}
