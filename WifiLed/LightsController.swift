//
//  LightsController.swift
//  DonsWebViewProject
//
//  Created by Gooduo on 17/1/9.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation

class LightsController{
    static let COLOR_NUM=7
    fileprivate var mLightList :[Light];
    fileprivate var mCloudCode:[UInt8]=[0xaa,0x08,0x0a,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0e]
    fileprivate var mFlashCode:[UInt8]=[0xaa,0x08,0x0a,0x05,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0f]
    fileprivate var mMoonCode:[UInt8]=[0xaa,0x08,0x0a,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x10]
    fileprivate var mManualCode:[UInt8]
    
    init(){
        mManualCode=[UInt8]()
        mLightList=[Light]();
        for i in 0 ..< LightsController.COLOR_NUM {
            mLightList.append(Light(Color: i+1))
            mManualCode.append(mLightList[i].getManuelLevel())
        }
        mCloudCode=[0xaa,0x08,0x0a,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0e]
        mFlashCode=[0xaa,0x08,0x0a,0x05,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0f]
        mMoonCode=[0xaa,0x08,0x0a,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x10]
    }
    
    private func codeInit(){
        mManualCode=[UInt8]()
        mLightList=[Light]();
        for i in 0 ..< LightsController.COLOR_NUM {
            mLightList.append(Light(Color: i+1))
            mManualCode.append(mLightList[i].getManuelLevel())
        }
        mCloudCode=[0xaa,0x08,0x0a,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0e]
        mFlashCode=[0xaa,0x08,0x0a,0x05,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0f]
        mMoonCode=[0xaa,0x08,0x0a,0x06,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x10]

    }

    internal func setAuto(_ color:Int,time:Int,level:Int) ->[UInt8]?{
        let temp=mLightList[color].setPoint(time,level:level);
        return temp;
    }
    internal func unset(_ color:Int,time:Int) ->[UInt8]?{
        let temp=mLightList[color].removeKey(time)
        return temp
    }
    
    internal func setManual(_ color:Int,level:Int)->[UInt8] {
        let code = mLightList[color].setManuelLevel(level)
        mManualCode[color]=UInt8(level & 0xff)
        return code;
    }
    internal func setCloud(_ stu:Bool,probability:Int,mask:Int) ->[UInt8]{
        var sProbability=probability;
        var sMask=mask;
        var sStu:UInt8=0x01;
//        var data = [UInt8](count:Light.CODE_LENGTH,repeatedValue:0x00);
        if(!stu){
            sProbability=0;
            sMask=0;
            sStu=0x00;
        }
        mCloudCode[4]=sStu;
        mCloudCode[5]=UInt8(sProbability & 0xff);
        mCloudCode[6]=UInt8(sMask);
        mCloudCode[11]=UInt8(0x04+0x0a+Int(sStu)+sProbability+sMask)
        
        return mCloudCode;
    }
    internal func setFlash(_ stu:Bool,level:Int,probability:Int) ->[UInt8]{
        var sProbability=probability;
        var sLevel=level;
        var sStu:UInt8=0x01;
        let data = [UInt8](repeating: 0x00,count: Light.CODE_LENGTH);
        if(!stu){
            sProbability=0;
            sLevel=0;
            sStu=0x00;
        }

        mFlashCode[4]=sStu;
        mFlashCode[5]=UInt8(sProbability & 0xff);
        mFlashCode[6]=UInt8(sLevel);
        mFlashCode[11]=UInt8(0x05+0x0a+Int(sStu)+sProbability+sLevel)
        return data
    }
    internal func setMoon(_ stu:Bool,startH:Int,startM:Int,endH:Int,endM:Int) ->[UInt8]{
        var sStartH=startH,sStartM=startM,sEndH=endH,sEndM=endM;
        var sStu: UInt8=0x01;
        if(!stu){
            sStu=0x00;
            sStartH=0;
            sStartM=0;
            sEndH=0;
            sEndM=0;
        }
        mMoonCode[4]=sStu;
        mMoonCode[6]=UInt8(sStartH & 0xff);
        mMoonCode[7]=UInt8(sStartM & 0xff);
        mMoonCode[8]=UInt8(sEndH & 0xff);
        mMoonCode[9]=UInt8(sEndM & 0xff);
        mMoonCode[11]=UInt8(0x06+0x0a+Int(sStu)+sStartH+sStartM+sEndH+sEndM)
        return mMoonCode;
    }
    internal func setTime() ->[UInt8]{
        let now = Date()
        let formater = DateFormatter()
        formater.dateFormat="yyyy,MM,dd,HH,mm,ss"
        let timeString=formater.string(from: now)
        let timeList=timeString.components(separatedBy: ",")
        let Y=UInt8(Int(timeList[0])!-1970)
        let M=UInt8(timeList[1])!
        let d=UInt8(timeList[2])!
        let h=UInt8(timeList[3])!
        let m=UInt8(timeList[4])!
        let s=UInt8(timeList[5])!
        let code:[UInt8]=[0xaa,0x08,0x0a,0x09,Y,M,d,h,m,s,0,(0x0a&+0x09&+Y&+M&+d&+h&+m&+s)]
        print(code)
        return code
    }
    internal func setAutoRun() ->[UInt8]{
        return [0xaa,0x08,0x0a,0x08,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x13]
    }
    internal func setSaveCode() ->[UInt8]{
        return [0xaa,0x08,0x0a,0x07,0xa5,0x00,0x00,0x00,0x00,0x00,0x00,0xb6]
    }
    internal func setRamRequestCode() ->[UInt8]{
        return [0xaa,0x08,0x0a,0x0a,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x14]
    }
    
    private func getJsonAutoMap() -> String{
        var base = [String:[String:Int]]()
        for i in 0 ..< LightsController.COLOR_NUM {
            var maps=mLightList[i].getControlMap();
            for j in 0 ..< Light.TOTAL {
                if maps[j].isKey(){
                    if nil==base[String(i)]{base[String(i)]=[String:Int]()}
                    base[String(i)]![String(j)]=maps[j].getLevel()
                }
            }
        }
        print(base);
        let strData = DataHandler.Dictionary2Json(dic: base)
        print(strData!);
        return strData!
        
    }
    
    
    private func setAutoMap(data:String){
        let myJson=JSON(DataHandler.string2Data(source: data));
        for (color,sub):(String,JSON) in myJson {
            for (time,level):(String,JSON) in sub {
                print(level.intValue);
                var _=setAuto(Int(color)!,time:Int(time)!,level:level.intValue)
            }
        }

    }
    private func initAutoMap(){
        for i in 0 ..< LightsController.COLOR_NUM {
            for j in 0 ..< Light.TOTAL {
                mLightList[i].setControlMap(j, key: false, level: 0)
                
            }
        }
    }
    private func getJsonManual() ->String{
        var base = [String:Int]();
        for i in 0 ..< LightsController.COLOR_NUM {
            base[String(i)] = Int(mLightList[i].getManuelLevel());
        }
        return DataHandler.Dictionary2Json(dic: base)!
        
    }
    private func setManualMap(data:String){
        let myJson=JSON(DataHandler.string2Data(source: data))
        for (key,value):(String,JSON) in myJson {
            var _=self.setManual(Int(key)!, level: value.intValue)
        }
    }
    private func getJsonCloud() -> String{
        var base=[String:Int]();
        base["stu"]=Int(mCloudCode[4])
        base["prob"]=Int(mCloudCode[5])
        base["mask"]=Int(mCloudCode[6])
        return DataHandler.Dictionary2Json(dic: base)!
    }
    private func setCloudMap(data:String){
        let myJson=JSON(DataHandler.string2Data(source: data));
        let stu = 0 == myJson["stu"].intValue ? false : true
        var _=setCloud(stu,probability: myJson["prob"].intValue,mask: myJson["mask"].intValue)
    }
    private func getJsonFlash() -> String{
        var base=[String:Int]();
        base["stu"]=Int(mFlashCode[4])
        base["prob"]=Int(mFlashCode[5])
        base["level"]=Int(mFlashCode[6])
        return DataHandler.Dictionary2Json(dic: base)!
    }
    private func setFlashMap(data:String){
        let myJson=JSON(DataHandler.string2Data(source: data))
        let stu = 0 == myJson["stu"].intValue ? false : true
        var _=setFlash(stu,level: myJson["level"].intValue,probability: myJson["prob"].intValue)

    }
    private func getJsonMoon() ->String{
        var base=[String:Int]();
        base["stu"]=Int(mMoonCode[4])
        base["startH"]=Int(mMoonCode[6])
        base["startM"]=Int(mMoonCode[7])
        base["endH"]=Int(mMoonCode[8])
        base["endM"]=Int(mMoonCode[9])
        return DataHandler.Dictionary2Json(dic: base)!
    }
    private func setMoonMap(data:String){
        let myJson=JSON(DataHandler.string2Data(source: data))
        let stu = 0 == myJson["stu"].intValue ? false : true
        var _=setMoon(stu,startH: myJson["startH"].intValue,startM: myJson["startM"].intValue,endH: myJson["endH"].intValue,endM: myJson["endM"].intValue)
    }
    internal func initCode(codeCollect:[(String,String)]?){
        codeInit()
        if nil != codeCollect {
            for (type,code) in codeCollect! {
                switch type{
                case Db.TYPE_AUTO:
                    setAutoMap(data: code)
                    break
                case Db.TYPE_MANUAL:
                    setManualMap(data: code)
                    break;
                case Db.TYPE_CLOUD:
                    setCloudMap(data: code)
                    break
                case Db.TYPE_FLASH:
                    setFlashMap(data: code)
                    break
                case Db.TYPE_MOON:
                    setMoonMap(data: code)
                    break
                default:
                    break
                    
                }
            }
        }
        
        
        
    }
    internal func getCodeJson(type:String) ->String{
        
        var data:String="{}"
        switch type{
        case Db.TYPE_AUTO:
            data = getJsonAutoMap()
            break
        case Db.TYPE_MANUAL:
            data = getJsonManual()
            break;
        case Db.TYPE_CLOUD:
            data = getJsonCloud()
            break
        case Db.TYPE_FLASH:
            data = getJsonFlash()
            break
        case Db.TYPE_MOON:
            data = getJsonMoon()
            break
        default:
            break
            
        }
        return data
        
    }



    
    
    
    
    
}
