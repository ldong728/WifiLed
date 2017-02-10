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
    fileprivate var mThreadFlag:Bool=false
    fileprivate var mSendSemaphore=DispatchSemaphore(value:1)
    fileprivate let mQueue : DispatchQueue
    fileprivate var mIPMap:[String:String]=[String:String]()
    fileprivate var mSendBuffer:Dictionary<String,Set<Code>>=[String:Set<Code>]()
    fileprivate var buffer:[String:DataPack?]=[String:DataPack]()
    fileprivate var mSocket: GCDAsyncUdpSocket!
    fileprivate let mLightController : LightsController
    fileprivate let mDb:Db
    
    
    override init(){
        mQueue=DispatchQueue(label: "data_udp")
        mLightController = LightsController()
        mDb=Db()
        super.init()
        mSocket=GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.global())
        initBuffers()
        initUdp()

        
        
    }
    fileprivate func initBuffers(){
        if(mIPMap.count>0){
            objc_sync_enter(mSendBuffer);
            mSendBuffer.removeAll();
            for(_,ip) in mIPMap {
                if ip != "0.0.0.0" {
                    mSendBuffer[ip]=Set<Code>()
                }
            }
            objc_sync_exit(mSendBuffer)
        }
//        mSendBuffer["172.22.11.1"]=Set<Code>()
        
    }
    fileprivate func initGroup(){
        mIPMap.removeAll();
        buffer.removeAll();
        let defaultIp = mDb.mCurrentGroupType==Db.GROUP_TYPE_ONLINE ? "0.0.0.0" : LightControllerGroup.DEFALT_IP
        let macList=mDb.getDeviceMacList()
        for mac in macList {
            mIPMap[mac]=defaultIp
        }
        initBuffers();
    }
    fileprivate func reflushDeviceIp(mac:String,newip:String){
        if nil != mIPMap[mac]{
            mIPMap[mac]=newip
            objc_sync_enter(mSendBuffer)
            mSendBuffer.removeValue(forKey: mIPMap[mac]!)
            mSendBuffer[newip]=Set<Code>()
            objc_sync_exit(mSendBuffer)
        }
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

    fileprivate func formatReceivedCode(revPacket :DataPack) -> DataPack? {
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
        let packData=pack.getData()
        let list :Set<Code>?=mSendBuffer[ip]
        var confirmed :Set<Code>=Set<Code>()
        var newList:Set<Code>?
        if list != nil {
            confirmed = getCodeSet(data: packData)
            newList=list!.subtracting(confirmed)
            objc_sync_enter(mSendBuffer)
            if newList != nil {
                mSendBuffer[ip]=newList!
            }else{
//                mSendBuffer.removeValue(forKey: ip)
            }
            objc_sync_exit(mSendBuffer)
        }
        
        
        
//        mSendSemaphore.signal()
    }
    
    fileprivate func putCodeToQueue(code:[UInt8]){
        let codeTypeSet=getCodeTypeSet(data: code)
        let newCodeList=getCodeSet(data: code)        
        objc_sync_enter(mSendBuffer)
        for (ip,oldList) in mSendBuffer {
            var regroupList:Set<Code>=Set<Code>()
            oldList.forEach{(data) ->Void in
                if !codeTypeSet.contains(data.TypeValue) {
                    regroupList.insert(data)
                }
            }
            mSendBuffer[ip]=newCodeList.union(regroupList)
        }
        objc_sync_exit(mSendBuffer)
        mSendSemaphore.signal()
    }
    fileprivate func getCodeSet(data:[UInt8]) -> Set<Code>{
        var confirmed :Set<Code>=Set<Code>()
            for i in 0 ..< data.count/Light.CODE_LENGTH {
                var subData = Array<UInt8>(data[i*Light.CODE_LENGTH ... ((i+1)*Light.CODE_LENGTH)-1])
                subData[2]=0x0a
                confirmed.insert(Code(subData))
            }
        return confirmed

    }
    
    fileprivate func getCodeTypeSet(data:[UInt8]) -> Set<String>{
        var confirmed :Set<String>=Set<String>()
        for i in 0 ..< data.count/Light.CODE_LENGTH {
            let subData = Array<UInt8>(data[i*Light.CODE_LENGTH ... ((i+1)*Light.CODE_LENGTH)-1])
            confirmed.insert(Code(subData).TypeValue)
        }
        return confirmed
    }
    fileprivate func sendCodeQueue(){
        
        while mThreadFlag {
            var codeCount=0
            mSendBuffer.forEach{(key,val) in
                if val.count>0 {
                    codeCount += val.count
                    val.forEach{(data) in
                        send(byteMessage:data.dataArray,ip:key,port:LightControllerGroup.DATA_PORT)
                        NSLog("send from queue")
                        Thread.sleep(forTimeInterval: 0.5)
                    }
                }
            }
            if codeCount == 0 {
                mSendSemaphore.wait()
            }
        }
    }
    fileprivate func preReceiveHandler(receiveDataPack:DataPack) ->Bool{
        let rcvString=String(bytes: receiveDataPack.getData(), encoding: String.Encoding.ascii)
        let rcvList=rcvString!.components(separatedBy: ",")
        let ip:String?=rcvList[0]
        let mac:String?=rcvList[1]
        if ip != nil && mac != nil {
            send(message: "AT+ENTM\r\n", ip: receiveDataPack.getIp(), port: receiveDataPack.getPort())
            if ip==LightControllerGroup.DEFALT_IP && mIPMap.count==0 {
               _=mDb.addDevice(mac: mac!)
                initGroup()
                return true
                
            }else{
                reflushDeviceIp(mac: mac!, newip: ip!)
                return true
            }
            
        }
        return false
    }
    internal func startSendQueue(){
        mThreadFlag = true
        mQueue.async {
            self.sendCodeQueue()
        }
    }
    
    internal func setAuto(color:Int,time:Int,level:Int,send:Bool=true){
        let data=mLightController.set(color, time: time, level: level)
        putCodeToQueue(code: data!)
    }
    internal func setManual(color:Int,level:Int){
        let data=mLightController.setManual(color, level: level)
        putCodeToQueue(code: data)
    }
    internal func setCloud(probability:Int,mask:Int,stu:Bool){
        let data=mLightController.setCloud(stu, probability: probability, mask: mask)
        putCodeToQueue(code: data)
    }
    internal func setFlash(probability:Int,level:Int,stu:Bool){
        let data=mLightController.setFlash(stu, level: level, probability: probability)
        putCodeToQueue(code: data)
    }
    internal func setMoon(startH:Int,startM:Int,endH:Int,endM:Int,stu:Bool){
        let data=mLightController.setMoon(stu, startH: startH, startM: startM, endH: endH, endM: endM)
        putCodeToQueue(code: data)
    }
    internal func searchDevice(){
        send(message:"www.usr.cn",ip:"255.255.255.255",port:48899)
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
        let receivedData=DataPack(data: data,address:address)
        if LightControllerGroup.DATA_PORT == receivedData.getPort(){
            let sData = formatReceivedCode(revPacket: receivedData)
            if nil != sData {
                reGroupSendQueue(pack: sData!)
            }
        }else{
            guard preReceiveHandler(receiveDataPack: receivedData) else {
//                print("can't handle")
                return
            
            }
        
        }
        
//        NSLog("ip: " + receiveedData.getIp())
//        NSLog("port: " + String(receiveedData.getPort()))
//        NSLog("data: \(receiveedData.getData())")
//        
//        var list:[UInt8]=[UInt8]()
//        address.forEach{(value:UInt8)-> Void in
//            list.append(value)
//        }
//        NSLog("address: \(list)")
//        let addr=String(data:data,encoding:String.Encoding.ascii)!
//        NSLog("receaved data: " + addr)

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



