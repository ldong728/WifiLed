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
        return strData
    }
    
    class func Dictionary2Json(dic:Dictionary<String,Any>) ->String?{
        let data = try? JSONSerialization.data(withJSONObject: dic,options:JSONSerialization.WritingOptions.prettyPrinted);
        let strData = String(data:data!,encoding:String.Encoding.utf8)
        return strData
    }
    
    class func string2Data(source: String) ->Data {
        let data=source.data(using: .utf8, allowLossyConversion:false);
        return data!;
    }
    
}
