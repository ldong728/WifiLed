//
//  LightControllerGroup.swift
//  WifiLed
//
//  Created by Gooduo on 17/1/17.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class LightControllerGroup: NSObject, GCDAsyncUdpSocketDelegate{
    static let DATA_PORT:UInt16 = 8899
    static let CTR_PORT:UInt16 = 48899
    static let BROADCAST_IP="255.255.255.255"
    static let DEFALT_IP="172.22.11.1"
    static let LOCAL_PORT:UInt16=26000
    fileprivate let mQueue : DispatchQueue
    fileprivate var mIPMap:[String:String]=[String:String]()
    fileprivate var mSendBuffer:Dictionary<String,Set<Code>>=[String:Set<Code>]()
    fileprivate var buffer:[String:DataPack?]=[String:DataPack]()
    fileprivate var mSocket: GCDAsyncUdpSocket!
    internal var mLightsController : LightsController
    
    
    
    override init(){
        mQueue=DispatchQueue(label: "data_udp")
        mLightsController = LightsController()
        super.init()
        mSocket=GCDAsyncUdpSocket(delegate: self, delegateQueue: mQueue)
        initUdp()

        
        
    }
    fileprivate func initUdp(){
        do{
            try mSocket.bind(toPort: LightControllerGroup.LOCAL_PORT)
            try mSocket.enableBroadcast(true)
            try mSocket.beginReceiving()
            
        }catch let e as NSError {
            NSLog(e.description)
        }
    }

    fileprivate func formatReceive(revPacket :DataPack) -> DataPack? {
        if revPacket.getLength() % Light.CODE_LENGTH != 0 {
            let sBuff:DataPack?=buffer[revPacket.getIp()]!
            if sBuff != nil {
                sBuff!.merge(otherPack: revPacket)
                if(sBuff!.getLength()%Light.CODE_LENGTH == 0){
                    buffer[sBuff!.getIp()]=nil
                    return sBuff
                }else{
                    buffer[sBuff!.getIp()]=sBuff!
                    return nil
                }
            } else {
                buffer[sBuff!.getIp()]=sBuff
                return nil;
            }
            
            
            
        }
        return revPacket
    }
    fileprivate func reGroupSendQueue(pack:DataPack){
        let ip = pack.getIp()
        let list :Set<Code>?=mSendBuffer[ip]!
        var confirmed :Set<Code>=Set<Code>()
        let packData=pack.getData()
        var newList:Set<Code>?
        if list != nil {
            confirmed = getCodeSet(data: packData)
            newList=list?.subtracting(confirmed)

        }
        objc_sync_enter(mSendBuffer)
        mSendBuffer[ip]=newList!
        objc_sync_exit(mSendBuffer)
    }
    fileprivate func putCodeToQueue(code:[UInt8]){
        let orderedCode=getCodeTypeSet(data: code)
        objc_sync_enter(mSendBuffer)
        for (ip,oldList) in mSendBuffer {
            var regroupList:Set<CodeType>=Set<CodeType>()
            oldList.forEach{(data) ->Void in
                regroupList.insert(CodeType(data))
            }
            let newCodeList=regroupList.symmetricDifference(orderedCode)
            mSendBuffer[ip]=newCodeList
            
        }
        objc_sync_exit(mSendBuffer)
    }
    
    fileprivate func getCodeSet(data:[UInt8]) -> Set<Code>{
        var confirmed :Set<Code>=Set<Code>()
            for i in 0 ..< data.count/Light.CODE_LENGTH {
                var subData = Array<UInt8>(data[i*Light.CODE_LENGTH ..< ((i+1)*Light.CODE_LENGTH)-1])
                subData[2]=0x0a
                confirmed.insert(Code(subData))
            }
        return confirmed

    }
    
    fileprivate func getCodeTypeSet(data:[UInt8]) -> Set<CodeType>{
        var confirmed :Set<CodeType>=Set<CodeType>()
        for i in 0 ..< data.count/Light.CODE_LENGTH {
            var subData = Array<UInt8>(data[i*Light.CODE_LENGTH ..< ((i+1)*Light.CODE_LENGTH)-1])
            subData[2]=0x0a
            confirmed.insert(CodeType(subData))
        }
        return confirmed
    }
    
    
    
    internal func send(message:String,ip:String=LightControllerGroup.DEFALT_IP,port:UInt16 = LightControllerGroup.DATA_PORT){
        print(message);
        let data = message.data(using: String.Encoding.ascii)
        NSLog("sended Data encode to Data: " + String(data:data!,encoding:String.Encoding.ascii)!)
        
        mSocket.send(data!,toHost:ip,port:port,withTimeout:2, tag:0)
        print("send ok")
    }
    internal func send(byteMessage: [UInt8],ip:String=LightControllerGroup.DEFALT_IP,port:UInt16 = LightControllerGroup.DATA_PORT){
        NSLog("sendDtat:" + String(describing: byteMessage));
        let data=Data(bytes: byteMessage,count: byteMessage.count)
        mSocket.send(data, toHost: ip, port: port, withTimeout: 2, tag: 0)
        NSLog("send ok");
    }
    
    /**
    接收数据后的方法
     **/
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        NSLog("receaved!!!!" + String(describing: data))
        var receiveedData=DataPack(data: data,address:address)
        NSLog("ip: " + receiveedData.getIp())
        NSLog("port: " + String(receiveedData.getPort()))
        NSLog("data: \(receiveedData.getData())")
        
        var list:[UInt8]=[UInt8]()
        address.forEach{(value:UInt8)-> Void in
            list.append(value)
        }
        NSLog("address: \(list)")
        let addr=String(data:data,encoding:String.Encoding.ascii)!
        NSLog("receaved data: " + addr)

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




    
    
}



