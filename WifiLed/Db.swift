//
//  Db.swift
//  WifiLed
//
//  Created by Gooduo on 17/2/7.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation
import SQLite

class Db : NSObject {
    
    static let DB_PATH="/Documents/db.sqlite3"
    var db:Connection!
    let GROUP_TBL=Table("GROUP_tbl")
    let DEVICE_TBL=Table("DEVICE_TBL")
    let CODE_TBL=Table("CODE_TBL")
    let USER_TBL=Table("USER_TBL")
    let OFFLINE_TBL=Table("OFFLINE_tbl")
    let U_ID=Expression<Int64>("U_ID")
    let U_NAME=Expression<String>("U_NAME")
    let U_EMAIL=Expression<String>("U_EMAIL")
    let U_PHONE=Expression<String>("U_PHONE")
    let U_PASD=Expression<String>("U_PASD")
    let U_DEFAULT=Expression<String>("U_DEFAULT")
    let U_SN=Expression<String>("U_SN")
    let G_ID=Expression<Int64>("G_ID")
    let G_INF=Expression<String>("G_INF")
    let G_NAME=Expression<String>("G_NAME")
    let G_SSID=Expression<String>("G_SSID")
    let G_SSID_PASD=Expression<String>("G_SSID_PASD")
    static let GROUP_TYPE_LOCAL="local"
    static let GROUP_TYPE_ONLINE="online"
    let D_MAC=Expression<String>("D_MAC")
    let D_SSID=Expression<String>("D_SSID")
    let D_IP=Expression<String>("D_ID")
    let D_TYPE=Expression<String>("D_TYPE")
    let D_NAME=Expression<String>("D_NAME")
    let C_ID=Expression<Int64>("C_ID")
    let C_TYPE=Expression<String>("C_TYPE")
    let G_TYPE=Expression<String>("G_TYPE")
    let C_CODE=Expression<String>("C_CODE")
    static let TYPE_AUTO="TYPE_AUTO"
    static let TYPE_MANUAL="TYPE_MANUAL"
    static let TYPE_CLOUD="TYPE_CLOUD"
    static let TYPE_FLASH="TYPE_FLASH"
    static let TYPE_MOON="TYPE_MOON"
    static let TYPE_OTHER="TYPE_OTHER"
    let DATA_TYPE=Expression<String>("DATA_TYPE")
    let DATA=Expression<String>("DATA")
    let TIMESTAMP=Expression<String>("TIMESTAMP")
    var SYN=Expression<Int64>("SYN")
    var mCurrentUserId:Int64 = -1;
    var mCurrentGroupId:Int64 = -1;
    var mCurrentGroupType=Db.GROUP_TYPE_LOCAL
    
    
    var tempStatus:Bool=true
    
    
    override init(){
        super.init()
        db = try! Connection(NSHomeDirectory()+Db.DB_PATH)
        createTbls()
        
    }
    
    func createTbls(){
        do{
            try db.run("CREATE TABLE IF NOT EXISTS USER_TBL (U_ID integer primary key autoincrement,U_NAME text,U_EMAIL text,U_PHONE text,U_PASD text,U_DEFAULT integer,U_SN text,SYN integer)")
            try db.run("CREATE TABLE IF NOT EXISTS GROUP_TBL (G_ID integer primary key autoincrement,G_NAME text,U_ID integer,G_INF text,G_TYPE text,G_SSID text,G_SSID_PASD text,SYN integer)")
            try db.run("CREATE TABLE IF NOT EXISTS DEVICE_TBL (D_MAC text primary key,D_SSID text,G_ID integer,D_TYPE text,D_NAME text,SYN integer)")
            try db.run("CREATE TABLE IF NOT EXISTS CODE_TBL (C_ID integer primary key autoincrement,G_ID integer,C_TYPE text,C_CODE String,SYN integer,UNIQUE(G_ID,C_TYPE))")
        }catch{
            tempStatus=false
            print(error)
        }
    }
    func getDeviceGroupId(mac:String) ->Int{
        var id:Int = -1
        let query = DEVICE_TBL.filter(D_MAC == mac);
        do{
            for data in try db.prepare(query){
                id=Int(data[G_ID])
            }
        }catch{
            print(error)
        }
        return id
    }
    
    func initDb(){
            mCurrentUserId=addUser("defaultUser")
    }
    func addUser(_ name:String) ->Int64{
        let data=USER_TBL.insert(U_NAME <- name);
        do{
            let id=try db.run(data)
            return id;
        }catch{
            print(error)
            return -1
        }
    }
    func addGroup(groupName:String) -> Int64{
        let data=GROUP_TBL.insert(U_ID <- mCurrentUserId,G_NAME <- groupName,G_TYPE <- Db.GROUP_TYPE_LOCAL)
        do {
            let id=try db.run(data)
            setGroupId(gId: Int(id))
            return id
            
        }catch{
            print(error)
            return -1
        }
    }
    func getGroupList(type:String)->String{
        var query: AnySequence<Row>?
        var result:[Dictionary]=[Dictionary<String,String>]()
        do{
            if "all" == type {
                query = try db.prepare(GROUP_TBL)
            }else{
                query = try db.prepare(GROUP_TBL.filter(G_TYPE == type))
            }
        }catch{
            print(error)
        }
        if nil != query {
            for row in query! {
                var dic = [String:String]()
                dic["G_ID"]=String(row[G_ID])
                dic["G_NAME"]=row[G_NAME]
                result.append(dic)
            }
//            let a =CharacterSet.whitespaces
            return DataHandler.Array2Json(array: result)!
        }
        return ""
        
    }
    func setGroupId(gId:Int){
        self.mCurrentGroupId=Int64(gId)
        let query=GROUP_TBL.filter(G_ID == self.mCurrentGroupId)
        do{
            for data in try db.prepare(query){
                mCurrentGroupType=data[G_TYPE]
            }
        }catch{
            print(error)
        }
    }
    func getGroupInf(groupid:Int64) ->Dictionary<String,String>{
        var inf:Dictionary<String,String>=[String:String]()
        let query=GROUP_TBL.filter(G_ID == groupid)
        do{
            for data in try db.prepare(query){
                inf["G_ID"]=String(data[G_ID])
                inf["G_NAME"]=data[G_NAME]
                inf["G_TYPE"]=data[G_TYPE]
                if mCurrentGroupType == Db.GROUP_TYPE_ONLINE {
                    inf["G_SSID"]=data[G_SSID]
                    inf["G_SSID_PASD"]=data[G_SSID_PASD]
                }

            }
        }catch{
            print(error)
        }
        return inf
    }
    
    func addDevice(mac:String) ->Int64{
        let data=DEVICE_TBL.insert(D_MAC <- mac,D_TYPE <- "light", D_NAME <- "light", G_ID <- mCurrentGroupId)
        do{
            let id=try db.run(data)
            return id
        }catch{
            print(error)
            return -1
        }
    }
    
    func getDeviceMacList() ->[String]{
        let query=DEVICE_TBL.filter(G_ID == mCurrentGroupId)
        var returnData = [String]()
        for data in try! db.prepare(query){
            returnData.append(data[D_MAC])
        }
        return returnData
    }
    
    func changeGroupType(ssid:String,pasd:String){
        let filter = GROUP_TBL.filter(G_ID == mCurrentGroupId)
        do{
            try db.run(filter.update(G_SSID <- ssid, G_SSID_PASD <- pasd, G_TYPE <- Db.GROUP_TYPE_ONLINE))
            mCurrentGroupType = Db.GROUP_TYPE_ONLINE
            
        }catch{
            print(error)
        }
    }
    func changeDeviceGroup(fromGroupId:Int64,toGroupId:Int64){
        let filter = DEVICE_TBL.filter(G_ID == fromGroupId)
        do{
            try db.run(filter.update(G_ID <- toGroupId))
        }catch{
            print(error)
        }
        
    }
    func addDevice(mac:String,ssid:String,name:String="my device"){
        let data = DEVICE_TBL.insert(or:OnConflict.replace,D_MAC <- mac,D_SSID <- ssid, G_ID <- mCurrentGroupId, D_NAME <- name)

        do{
            _ = try db.run(data)
        }catch{
            print(error)
        }
    }
    public func setCode(type:String,code:String){
        let data = CODE_TBL.insert(or:OnConflict.replace,G_ID <- mCurrentGroupId,C_TYPE <- type,C_CODE <- code)
        do{
            _ = try db.run(data)
        }catch{
            print(error)
        }
    }
    public func getCode() ->[(String,String)]{
        var array = [(String,String)]()
        do{
            for code in try db.prepare(CODE_TBL.filter(G_ID == mCurrentGroupId)){
                array.append((code[C_TYPE],code[C_CODE]))
            }
        }catch{
            print(error)
        }

        return array
    }
    public func getCode(type:String) ->String?{
        var returnCode:String?=nil
        var query = CODE_TBL.filter(G_ID == mCurrentGroupId)
        query=query.filter(C_TYPE == type)
        do{
            for data in try db.prepare(query){
                returnCode = data[C_CODE]
                break
            }
            return returnCode
        }catch{
            print(error)
            return nil
        }
        
    }
    
    func deleteTbl(){
        do{
            try db.run(USER_TBL.drop())
            try db.run(GROUP_TBL.drop())
            try db.run(DEVICE_TBL.drop())
            try db.run(CODE_TBL.drop())
            
        }catch{
            tempStatus=false
            print(error)
        }
    }
    func insert(){
        let insert=USER_TBL.insert(U_NAME <- "abcd",U_PHONE <- "123212121")
        
        do{
            try db.run(insert)
//            try db.run("insert into USER_TBL set U_NAME=\"bcda\",U_PHONE=\"0000000\",SYN=1")
        }catch{
            tempStatus=false
            print(error)
        }
        
    }

}
