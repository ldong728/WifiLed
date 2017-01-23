//
//  UdpController.swift
//  WifiLed
//
//  Created by Gooduo on 17/1/12.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
class UdpController : NSObject,GCDAsyncUdpSocketDelegate{
    static let DATA_PORT:UInt16 = 8899
    static let CTR_PORT:UInt16 = 48899
    static let BROADCAST_IP="255.255.255.255"
    static let DEFALT_IP="172.22.11.1"
    static var count=0
    fileprivate let id:Int
    fileprivate var broadcast:Bool=false
    fileprivate var ip:String?
    fileprivate var localPort :UInt16=26000;
    fileprivate var buffer :[String:[UInt8]]?
    fileprivate var queue : DispatchQueue!
    
    var socket:GCDAsyncUdpSocket!
    override init(){
        UdpController.count += 1
        id=UdpController.count
        queue=DispatchQueue(label:"udp")
        super.init()
        setupConnection()
        
    }
    func setupConnection(){
//        var error: NSError?
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: queue)
        do{
            try socket!.bind(toPort: localPort)
//            try socket!.connect(toHost: UdpController.DEFALT_IP,onPort:localPort)
            try socket!.beginReceiving()
            
        }catch let error as NSError{
            NSLog("error:\(error.domain)")
        }
    }
    func udpSocket(_ sock:GCDAsyncUdpSocket,didConnectToAddress address:Data){
        
        print("didConnectToAddress:" + String(data:address,encoding:String.Encoding.utf8)!)
    }
    func udpSocket(_ sock:GCDAsyncUdpSocket,didNotConnect error: Error?){
        
        NSLog("didNotConnect:\(error.debugDescription)")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket,didSendDataWithTag tag:Int){
        print("didSendDataWithTag")
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket,didNotSendDataWithTag tag: Int, dueToError error: Error?){
        NSLog("didNotSendDataWithTag" + error.debugDescription)
        
    }
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) { 
        NSLog("receaved!!!!" + String(describing: data))
        data.forEach{(body: UInt8)->Void in
            print(body)
        }
            
        
//        NSLog("receaved content= \(data)")
    }
    internal func send(message:String){
        print(message);
        let data = message.data(using: String.Encoding.utf8)
        NSLog("sended Data encode to Data" + String(data:data!,encoding:String.Encoding.utf8)!)
        
        socket.send(data!,withTimeout:2, tag:0)
        print("send ok")
    }
    internal func send(byteMessage: [UInt8],ip:String=UdpController.DEFALT_IP,port:UInt16 = UdpController.DATA_PORT){
        NSLog("sendDtat:" + String(describing: byteMessage));
        let data=Data(bytes: byteMessage,count: byteMessage.count)
        socket.send(data, toHost: ip, port: port, withTimeout: 2, tag: 0)
        NSLog("send ok");
    }

    internal func tempMethod(){
        queue.sync {
            for i in 0 ..< 2 {
                send(message: "sendData:" + String(i))
                DispatchQueue.main.async {
                    print("sendData in MainQueue" + String(i))
                }
            }
        }
        
    }
    
}

