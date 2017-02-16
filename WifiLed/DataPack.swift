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
    fileprivate let header:[UInt8] = [0xaa, 0x08, 0x0a]
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
    
        self.data += otherData
       
        return getData()
    }
    internal func merge(otherPack: DataPack) {
        if otherPack.isHead() {
            self.data = otherPack.getData()
        }else{
            self.data += otherPack.getData()
        }
//        return self
//        self.data+=otherPack.getData()
    }
    internal func isHead() ->Bool{
        if getData().count<3 {
            return false
        }
        return Array(self.data[0...2])==header
    }
    
}
