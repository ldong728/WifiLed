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
    var lc:LightControllerGroup!
//    var db:Db!
    override func setUp() {

        lc=LightControllerGroup()
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
            for _ in 1 ... 10 {
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
        lc.searchDevice()
        
        for _ in 1 ... 1000{
            Thread.sleep(forTimeInterval: 0.2)
        }
        XCTAssert(true);
    }
    func testDataGenerator(){
        var temp:Dictionary<String,[String]?>=[String:[String]?]()
        let data=temp["ab"]
        if data == nil {
            print("nothing")
        }
        XCTAssert(true);
        
    }
    func testDb(){
        let sDb=Db()
        sDb.deleteTbl()
        sDb.createTbls()
//        sDb.addUser("不可言说")
//        sDb.addGroup(groupName: "测试分组")
        print(sDb.getGroupList(type: "all"))
//        print(try! sDb.db.scalar(sDb.USER_TBL.count))
//        sDb.insert()
//        sDb.select()
        XCTAssert(sDb.tempStatus)
    }
    func testTemp(){
        
        XCTAssert(true)
    }
    
}
