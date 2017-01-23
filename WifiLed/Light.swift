//
//  Light.swift
//  DonsWebViewProject
//
//  Created by Gooduo on 17/1/6.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation

class Light {
    static let TOTAL=48;
    static let CODE_LENGTH=12;
    static let MAX=0x64;
    static let MIN=0x00;
    fileprivate var mColor : Int,mMaxLevel :Int,mMinLevel :Int;
    fileprivate var mLevel : Int=0;
//    private var mLevel :Int=0;
    fileprivate var mControlMap : Array<ControllerPoint>?;

    init(Color color :Int, maxLevel : Int=Light.MAX, minLevel :Int=Light.MIN)
    {
        let min=minLevel<Light.MIN ? Light.MIN : minLevel
        let max=maxLevel>Light.MAX ? Light.MAX : maxLevel
        mMaxLevel=max;
        mMinLevel=min;
        mColor=color;
        mControlMap=[ControllerPoint]()
        self.initControlMap();
    }
    fileprivate func initControlMap(){
        for i in 0 ..< Light.TOTAL{
            mControlMap!.append(ControllerPoint(index: i));
        }
    }
    fileprivate func setLevel(_ index : Int,level : Int)->[UInt8]{
//        var length=0;
        var buffer:[UInt8]=[UInt8]();
        var leftKey:Int=0;
        var rightKey:Int=index-1;
        var leftCount:Int=0,rightCount:Int=0,leftE:Int=0,rightE:Int=0;
        var leftOffsetCount:Int=0,rightOffsetCount:Int=0;
        var offset:Int=0;
        mControlMap![index].setKey(true);
        mControlMap![index].setLevel(level);
        buffer+=mControlMap![index].getCode(mColor);
        
        if index>0 {
            for sleftKey in (1..<index).reversed() {
                leftKey=sleftKey
                if mControlMap![sleftKey].isKey() {
                    break;
                }
                leftCount += 1;
            }
        }else{
            leftKey=0;
        }
        if index<Light.TOTAL-1 {
            
            for srightKey in index+1 ..< Light.TOTAL-1 {
                rightKey=srightKey
                if(mControlMap![srightKey].isKey()){break};
                rightCount += 1;
            }
        }else{
            rightKey=Light.TOTAL-1;
        }
        if leftCount>0 {
            leftE=(level-mControlMap![leftKey].getLevel())/(leftCount+1)
            leftOffsetCount=(level-mControlMap![leftKey].getLevel())%(leftCount+1);
            for i in 0 ..< leftCount {
                offset=i<abs(leftOffsetCount)-1 ? abs(leftOffsetCount)/leftOffsetCount :0
                mControlMap![index-i-1].setLevel(mControlMap![index-i].getLevel()-leftE-offset)
                buffer+=mControlMap![index-i-1].getCode(mColor)
            }
        }
        if rightCount>0 {
            rightE=(level-mControlMap![rightKey].getLevel())/(rightCount+1)
            rightOffsetCount=(level-mControlMap![rightKey].getLevel())%(rightCount+1);
            for j in 0 ..< rightCount {
                offset=j<abs(rightOffsetCount)-1 ? abs(rightOffsetCount)/rightOffsetCount :0
                mControlMap![index+j+1].setLevel(mControlMap![index+j].getLevel()-rightE-offset)
                buffer+=mControlMap![index+j+1].getCode(mColor)
                
            }
        }
        return buffer;
    }
    internal func setPoint(_ index:Int,level:Int)->[UInt8]?{
        if index > -1 && index<Light.TOTAL && level<Light.MAX+1 && level>Light.MIN-1 {
            let v=Double(level)/Double(100)*Double(mMaxLevel);
            return setLevel(index, level: Int(v))
        }
        return nil;
    }
    internal func getControlMap() ->[ControllerPoint]{
        return mControlMap!
    }
    internal func setManuelLevel(_ level :Int) ->[UInt8]{
        var data=[UInt8](repeating: 0x00,count: 12)
        data[0]=0xaa;
        data[1]=0x08;
        data[2]=0x0a;
        data[3]=0x01;
        data[4]=UInt8(mColor & 0xff);
        data[5]=UInt8(level & 0xff);
        data[11]=UInt8((0x01+0x0a+mColor+level)&0xff);
        mLevel=level;
        return data;
    }
    internal func getManuelLevel() -> UInt8{
        return UInt8(mLevel & 0xff);
    }
    internal func setControlMap(_ index:Int,key:Bool,level:Int){
        mControlMap![index].setKey(key)
        mControlMap![index].setLevel(level);
    }
    internal func display(){
        
    }
    internal func removeKey(_ index:Int) -> [UInt8]?{
        if(mControlMap![index].isKey()){
            mControlMap![index].setKey(false);
        }
        for i in (0 ... index).reversed(){
            if(mControlMap![i].isKey()){
                return setLevel(i, level: mControlMap![i].getLevel());
            }else if(i==0){
                let data=setLevel(i, level: 0);
                mControlMap![i].setKey(false);
                return data
            }
        }
        return nil
    }
    
    
    
}
