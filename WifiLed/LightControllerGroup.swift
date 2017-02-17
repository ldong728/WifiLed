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
    static let SEND_INTERVAL=0.02
    static let SEND_BREAK=0.5
    static let SCAN_WIFI:[UInt8]=[0xff,0x00,0x01,0x01,0x02]
    fileprivate var mThreadFlag:Bool=false
    fileprivate var mSamaphoreFlag:Bool=true
    fileprivate var mSendSemaphore=DispatchSemaphore(value:1)
    fileprivate let mQueue : DispatchQueue
    fileprivate var mTotalDeviceLinked:[String:String]=[String:String]()
    fileprivate var mIPMap:[String:String]=[String:String]()
    fileprivate var mSendBuffer:Dictionary<String,Set<Code>>=[String:Set<Code>]()
    fileprivate var buffer:[String:DataPack?]=[String:DataPack?]()
    fileprivate var mSocket: GCDAsyncUdpSocket!
    fileprivate let mLightController : LightsController
    fileprivate let mDb:Db
    var mToGroupId:Int = -1
    var mToSSID:String?
    var mToSSIDpasd:String?
    
    
    override init(){
        mQueue=DispatchQueue(label: "data_udp")
        mLightController = LightsController()
        mDb=Db()
        super.init()
        mSocket=GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue(label: "receive_thread"))
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
    public func initGroup(){
        mIPMap.removeAll();
        buffer.removeAll();
        let defaultIp = mDb.mCurrentGroupType==Db.GROUP_TYPE_ONLINE ? "0.0.0.0" : LightControllerGroup.DEFALT_IP
        let macList=mDb.getDeviceMacList()
        for mac in macList {
            if mTotalDeviceLinked.index(forKey: mac) != nil{
                mIPMap[mac]=mTotalDeviceLinked[mac]
            }else{
                mIPMap[mac]=defaultIp
            }
            
        }
        initBuffers();
        mLightController.initCode(codeCollect: mDb.getCode())
    }
    /**
     *根据mac值和对应IP刷新mac-ip列表
     *如有更新，返回true
    **/
    fileprivate func reflushDeviceIp(mac:String,newip:String)->Bool{
        if nil != mIPMap[mac]{
            if mIPMap[mac] != newip{
                mIPMap[mac]=newip
                objc_sync_enter(mSendBuffer)
                mSendBuffer.removeValue(forKey: mIPMap[mac]!)
                mSendBuffer[newip]=Set<Code>()
                objc_sync_exit(mSendBuffer)
                return true
            }
            return false
        }
        return false
    }
    /**
     *初始化socket对象
    **/
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
            

            if let sBuff = buffer[revPacket.getIp()]{
                sBuff!.merge(otherPack: revPacket)
                if(sBuff!.getLength()%Light.CODE_LENGTH == 0){
                    buffer.removeValue(forKey: sBuff!.getIp())
                    return sBuff
                }else{
                    buffer[sBuff!.getIp()]=sBuff!
                    return nil
                }
            } else {
                if revPacket.isHead(){
                    buffer[revPacket.getIp()] = revPacket
                }
                
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
            NSLog("regroup")
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
        guard mSamaphoreFlag else {
            mSamaphoreFlag=true
            mSendSemaphore.signal()
            return
        }
        
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
        NSLog("send Queue Started")
        while mThreadFlag {
            var codeCount=0
            mSendBuffer.forEach{(key,val) in
                if val.count>0 {
                    codeCount += val.count
                    val.forEach{(data) in
                        send(byteMessage:data.dataArray,ip:key,port:LightControllerGroup.DATA_PORT)
                        NSLog("send from queue \(codeCount) remaining")
                        Thread.sleep(forTimeInterval: LightControllerGroup.SEND_INTERVAL)
                    }
                    NSLog("=================queue sent \(codeCount) remeining====================")
                    Thread.sleep(forTimeInterval: LightControllerGroup.SEND_BREAK)
                }
                
            }
            if codeCount == 0 {
                mSamaphoreFlag=false
                mSendSemaphore.wait()
            }
        }
    }
    /**
     *对udp非控制数据端口接收到的数据进行预处理，可处理的返回true不可处理的返回false
    **/
    fileprivate func preReceiveHandler(receiveDataPack:DataPack) ->Bool{
        let rcvData=receiveDataPack.getData()
        if 0xff==rcvData[0] {  //usrLink 指令返回
            if 0x81==rcvData[3] {
                let ssidList=DataHandler.Array2Json(array: DataHandler.decodeWifiData(data: rcvData))
                JsBridge.getCurrentJsBridge()?.postToJs(method: "getWifi", param: ssidList)
            }
            if 0x82==rcvData[3] {
                if 0x01==rcvData[4]&&0x01==rcvData[5]{
                    if mToGroupId == -1{
                        mDb.changeGroupType(ssid: mToSSID!, pasd: mToSSIDpasd!)
                    }else{
                        mDb.changeDeviceGroup(fromGroupId: Int64(mDb.mCurrentGroupId), toGroupId: Int64(mToGroupId))
                        mDb.setGroupId(gId: mToGroupId)
                        
                    }
                    initGroup()
                    JsBridge.getCurrentJsBridge()!.postToJs(method: "ap2StaOk", param: String(mDb.mCurrentGroupId))
                }else{
                    JsBridge.getCurrentJsBridge()!.postToJs(method: "ap2StaFail")
                }
            }
            
            return true;
        }
        // 搜索指令返回
        let rcvString=String(bytes: receiveDataPack.getData(), encoding: String.Encoding.ascii)
        let rcvList=rcvString!.components(separatedBy: ",")
        if rcvList.count>1 {
            let ip:String?=rcvList[0]
            let mac:String?=rcvList[1]
            if ip != nil && mac != nil {
                print(ip!+":"+mac!)
                send(message: "AT+ENTM\r\n", ip: receiveDataPack.getIp(), port: receiveDataPack.getPort())
                mTotalDeviceLinked[mac!]=ip!
                if -1 == mDb.mCurrentGroupId { //是否为首页上
                    
                    if ip == LightControllerGroup.DEFALT_IP {//AP模式
                        let group_id=mDb.getDeviceGroupId(mac: mac!)
                        if -1 != group_id { //设备已在列表中
                            mDb.setGroupId(gId: group_id)
                            initGroup()
                            JsBridge.getCurrentJsBridge()!.postToJs(method: "groupSelected", param: String(group_id))
                            return true
                        }else{
                            JsBridge.getCurrentJsBridge()!.postToJs(method: "newDevice")
                            return true
                        }
                    }else{//Sta模式
                        return true
                    }
                }else{//非首页上
                    if ip == LightControllerGroup.DEFALT_IP {//本地模式
                        return true
                    }else{//在线模式
                        if reflushDeviceIp(mac: mac!, newip: ip!){
                            JsBridge.getCurrentJsBridge()?.postToJs(method: "flushLinkedDevice", param: mac)
                        }
                        return true
                    }
                }
            } 
        }
        
        return false

        
        
    }
    func send(message:String,ip:String=LightControllerGroup.DEFALT_IP,port:UInt16 = LightControllerGroup.DATA_PORT){
        print(message);
        let data = message.data(using: String.Encoding.ascii)
        NSLog("sended Data encode to Data: " + String(data:data!,encoding:String.Encoding.ascii)!)
        
        mSocket.send(data!,toHost:ip,port:port,withTimeout:2, tag:0)
//        print("send ok")
    }
    func send(byteMessage: [UInt8],ip:String=LightControllerGroup.DEFALT_IP,port:UInt16 = LightControllerGroup.DATA_PORT){
        NSLog("sendDtat:" + String(describing: byteMessage));
        let data=Data(bytes: byteMessage,count: byteMessage.count)
        mSocket.send(data, toHost: ip, port: port, withTimeout: 2, tag: 0)
//        NSLog("send ok");
    }
    
    /**
    接收数据后的方法
     **/
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        let receivedData=DataPack(data: data,address:address)
        NSLog("receive from "+receivedData.getIp()+" "+DataHandler.getStringOfUint8Array(data: receivedData.getData()))
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
    internal func startSendQueue(){
        mThreadFlag = true
        mQueue.async {
            self.sendCodeQueue()
        }
    }
    internal func setAuto(color:Int,time:Int,level:Int,isConfirm:Bool=true){
        var data:[UInt8]?
        if level>100||level<0 {
            data=mLightController.unset(color, time: time)
        }else{
            data=mLightController.setAuto(color, time: time,level:level)
        }
        
        if isConfirm {
            putCodeToQueue(code: data!)
        }
    }
    internal func setManual(color:Int,level:Int){
        let GroupType=mDb.mCurrentGroupType
        if Db.GROUP_TYPE_LOCAL == GroupType {
            send(byteMessage: mLightController.setManual(color, level: level))
        }else{
            let data=mLightController.setManual(color, level: level)
            putCodeToQueue(code: data)
            
        }
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
    internal func getGroupList(type:String) ->String{
        return mDb.getGroupList(type: type)
    }
    internal func searchDevice(){
        send(message:"www.usr.cn",ip:LightControllerGroup.BROADCAST_IP,port:LightControllerGroup.CTR_PORT)
    }
    internal func addGroup(name:String){
        _=mDb.addGroup(groupName: name)
        _=mDb.addDevice(mac: mTotalDeviceLinked.popFirst()!.0)
        initGroup()
        
    }
    internal func scanWifi(){
        send(byteMessage: LightControllerGroup.SCAN_WIFI, ip: LightControllerGroup.DEFALT_IP, port: LightControllerGroup.CTR_PORT)
    }
    internal func ap2Sta(ssid:String,pasd:String){
        send(byteMessage: DataHandler.generateLinkData(ssid: ssid, pasd: pasd), ip: LightControllerGroup.DEFALT_IP, port: LightControllerGroup.CTR_PORT)
    }
    internal func getCode(type:String)->String{
        let code=mLightController.getCodeJson(type: type)
        return code
    }
    internal func initDeviceTime(){
        for (_,ip) in mIPMap {
            if ip != "0,0,0,0" {
                send(byteMessage: mLightController.setTime(), ip: ip, port: LightControllerGroup.DATA_PORT)
            }
        }
    }
    internal func saveCode(type:String,saveToRam:Bool = true){
        if saveToRam {
            let code=mLightController.setSaveCode()
            putCodeToQueue(code: code)
            if type == Db.TYPE_AUTO {
                putCodeToQueue(code: mLightController.setAutoRun())
            }
        }
        mDb.setCode(type: type, code: mLightController.getCodeJson(type: type))
    }
    internal func setTime(ip:String=LightControllerGroup.BROADCAST_IP){
        let code=mLightController.setTime()
        if LightControllerGroup.BROADCAST_IP==ip {
            putCodeToQueue(code: code)
        }else{
            send(byteMessage: code, ip: ip)
        }
        
    }
    internal func getGroupDetail(groupId:Int = -1) ->String{
        let id:Int64 = -1==groupId ? mDb.mCurrentGroupId : Int64(groupId)
        let GroupInf=mDb.getGroupInf(groupid: id);
        let totalDeviceList=mDb.getDeviceMacList()
        return DataHandler.Dictionary2Json(dic: ["inf":GroupInf,"totalList":totalDeviceList,"linked":mIPMap])!
//        return DataHandler.Dictionary2Json(dic: mDb.getGroupInf())!
//        return  mDb.getGroupInf()
    }
    internal func getGroupInf(groupId:Int) ->Dictionary<String,String>{
        return mDb.getGroupInf(groupid:Int64(groupId))
        
    }
    internal func chooseGroup(groupId:Int){
        mDb.setGroupId(gId: groupId)
        initGroup();
        
    }





    
    
}



