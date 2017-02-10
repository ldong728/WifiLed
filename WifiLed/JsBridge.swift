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

        let method=jsonData["method"].stringValue
        switch method {
            case "getGroupList":
                print(jsonData["type"].stringValue)
                
                let back = postToJs(method: method+"Reply", param: "abc"){
                    (data,error) in
                    print(data as! String)
                }
                
            break

            case "wifi":
            
            break
            
        default:
            
            break
        }
    }
    
    func postToJs(method:String,param:String?,callBack:((_ data:Any?,_ error:Error?)->Void)?){

        let jsParam=nil != param ? "'"+param!+"'" : ""
        wk.evaluateJavaScript(method+"("+jsParam+")",completionHandler: callBack)
        
    }
    
    
}
