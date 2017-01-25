//
//  WifiLedTests.swift
//  WifiLedTests
//
//  Created by Gooduo on 17/1/12.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import XCTest
//import CocoaAsyncSocket
@testable import WifiLed

class WifiLedTests: XCTestCase {
    var lc:LightsController?
    var uc:LightControllerGroup?
    override func setUp() {
        lc=LightsController()
//        uc=LightControllerGroup()
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    func testMethod(){
        let CodeA=Code([0x99,0x89])
        let CodeB=Code([0x99,0x88])
        print(CodeA==CodeB)
        
        
        
        XCTAssert(true)
    }
    func temp(){
        print("ok")
    }
    func testGCD(){
        let workQueue = DispatchQueue(label:"work Thread")
        let controllerQuere = DispatchQueue(label: "controller Thread")
        var flag=true
        var count=0
//        var semaphore=DispatchSemaphore(value: 5)
        func sendThread(){
            while flag {
                count=count+1
                NSLog("work count: " + String(count) + "\(Thread.current)" )
                Thread.sleep(forTimeInterval: 0.2)
            }
        }
        func test(_ tag:String){
            for i in 1 ... 10 {
                Thread.sleep(forTimeInterval: 0.5)
                NSLog("tag: " + tag + "\(Thread.current)");
                
                
//                sleep(1)
//                semaphore.signal()
            }
        }
        workQueue.async {
            sendThread()
        }
        controllerQuere.sync {
            test("bbbbbbbbbb")
            flag=false
        }
        


        
        
        XCTAssert(true);
    }
    func testUDP(){
        let data=lc!.setManual(2, level: 25)
        uc!.send(message: "hello world",ip:"127.0.0.1",port: LightControllerGroup.LOCAL_PORT);
        
        XCTAssert(true);
    }
    func testType(){
        var testSet=Set<Code>()
        let v1=Code([0xaa,0x08,0x0a,0x01,0x02,0x06])
        let v2=Code([0xaa,0x08,0x0a,0x01,0x02,0x05])
        var v3: Code?
        if v1 is Code{
          v3=v1 as! CodeType
        }
        
        print(v1.hashValue)
        print(v2.hashValue)
        print(v3!.hashValue)
        XCTAssert(true);
    }
    
}
