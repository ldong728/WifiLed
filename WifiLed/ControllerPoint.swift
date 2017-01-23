//
//  ControllerPoint.swift
//  DonsWebViewProject
//
//  Created by Gooduo on 17/1/7.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import Foundation

class ControllerPoint{
    fileprivate var mIndex :Int;
    fileprivate var mKey : Bool;
    fileprivate var mLevel :Int;
    init(index :Int,key : Bool = false,level : Int=0x00){
        mIndex=index;
        mKey=key;
        mLevel=level;
    }
    internal func isKey() ->Bool{
        return mKey;
    }
    internal func setKey(_ key : Bool){
        self.mKey=key;
    }
    internal func setLevel(_ level:Int){
        self.mLevel=level;
    }
    internal func getLevel() -> Int{
        return mLevel;
    }
    internal func getCode(_ Color: Int)->[UInt8]{
        let h=mIndex/2;
        let hh=mIndex%2;
        var data=[UInt8](repeating: 0x00, count: Light.CODE_LENGTH);
        data[0]=0xaa;
        data[1]=0x08;
        data[2]=0x0a;
        data[3]=0x03;
        data[4]=UInt8(Color & 0xff);
        data[5]=UInt8(mLevel & 0xff);
        data[6]=UInt8(h & 0xff);
        data[7]=UInt8(hh & 0xff);
        data[11]=UInt8((Color+mLevel+h+hh+0x0a+0x03) & 0xff);
        return data;
    }
    
}
