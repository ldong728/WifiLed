//
//  DataHandler.swift
//  DonsWebViewProject
//
//  Created by Gooduo on 17/1/11.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation


class DataHandler{
    
    class func Array2Json(array:Array<Any>) ->String?{
        let data = try? JSONSerialization.data(withJSONObject: array,options:JSONSerialization.WritingOptions.prettyPrinted);
        let strData = String(data:data!,encoding:String.Encoding.utf8)
        let trimedData=strData?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
        return trimedData
    }
    
    class func Dictionary2Json(dic:Dictionary<String,Any>) ->String?{
        let data = try? JSONSerialization.data(withJSONObject: dic,options:JSONSerialization.WritingOptions.prettyPrinted);
        let strData = String(data:data!,encoding:String.Encoding.utf8)
        
        return strData?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: " ", with: "")
    }
    
    class func string2Data(source: String) ->Data {
        let data=source.data(using: .utf8, allowLossyConversion:false);
        return data!;
    }
    class func generateLinkData(ssid:String,pasd:String,index:UInt8=0x00) ->[UInt8]{
        let dataStr=ssid+"\r\n"+pasd
        let data:[UInt8]=[UInt8](dataStr.data(using: String.Encoding.ascii)!)
        let key:[UInt8]=[0x02,index]+data
        return generateCmd(key: key)
    }
    class func decodeWifiData(data:[UInt8])->[String]{
        var returnData=[String]()
        var ssidData=Array(data[5...data.count])
        var last=0
        for i in 0 ..< ssidData.count-1 {
            if ssidData[i]==0x0d && ssidData[i+1]==0x0a {
                let ssidBytes=Array(ssidData[last...i-2-last])
                returnData.append(String(bytes: ssidBytes, encoding: String.Encoding.utf8)!)
                last=i+2
            }
        }
        return returnData
        
    }
    
    private class func generateCmd(key:[UInt8])->[UInt8]{
        var cmd = [UInt8]()
        cmd.append(0xff)
        cmd.append((UInt8(key.count>>8))&0xff)
        cmd.append(UInt8(key.count)&0xff)
        var verify:UInt8=cmd[1]&+cmd[2]
        for i in 0 ..< key.count {
            verify=verify&+key[i]
        }
        cmd+=key
        cmd.append(verify)
        return cmd
        
    }
    
    
}
