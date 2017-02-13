//
//  JsBridge.swift
//  WifiLed
//
//  Created by Gooduo on 17/2/10.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation
import WebKit

class JsBridge {
    static var jb:JsBridge?
    let wk:WKWebView
    
    private init(wk:WKWebView){
        self.wk=wk
    }
    class func createJsBridge(wk:WKWebView) ->JsBridge{
        if jb == nil {
            jb=JsBridge(wk: wk)
        }
        return jb!
    }
    class func getCurrentJsBridge() ->JsBridge?{
        return jb
    }
    
    func handleJs(msg:WKScriptMessage,controller:LightControllerGroup){
        let jsonData=JSON(data: (msg.body as! String).data(using: String.Encoding.utf8)!)
        var param:String?
        let method=jsonData["method"].stringValue
        let data=jsonData["data"].stringValue
        switch method {
            
        case "getGroupList":
            param=controller.getGroupList(type: data)
            break
            
        case "addGroup":
            controller.addGroup(name: data)
            break
            
        case "searchDevice":
            
            controller.searchDevice()
            break
            
        default:
            NSLog("jsBridge can't find method")
            break
        }
        if nil != param {
            postToJs(method: method+"Reply", param: param)
        }else{
            postToJs(method: method+"Reply")
        }
    }
    
    func postToJs(method:String,param:String?=nil,callBack:((_ data:Any?,_ error:Error?)->Void)?=nil){

        let jsParam=nil != param ? "'"+param!+"'" : ""
        wk.evaluateJavaScript(method+"("+jsParam+")",completionHandler: callBack)
        
    }
    
    
}
