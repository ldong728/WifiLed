//
//  ViewController.swift
//  DonsWebViewProject
//
//  Created by Gooduo on 17/1/4.
//  Copyright © 2017年 Gooduo. All rights reserved.
//

import UIKit
import WebKit
class ViewController: UIViewController,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler{
    
    var wk: WKWebView!
    var mUdpController: LightControllerGroup!
//    var mLightController: LightsController!
    var jb:JsBridge!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                let conf=WKWebViewConfiguration()
        let filePath=Bundle.main.path(forResource: "assets/equip_index", ofType: "html")
        var fileURL=URL(fileURLWithPath: filePath!);
        //        var filePath = NSBundle.mainBundle().pathForResource("file", ofType: "pdf");
//        conf.userContentController.add(self, name: "wifi")
        conf.userContentController.add(self, name: "light")
        self.wk = WKWebView(frame: self.view.frame,configuration: conf)
        self.wk.navigationDelegate = self
        self.wk.uiDelegate = self
        self.jb=JsBridge.createJsBridge(wk: self.wk)


        
        self.mUdpController = LightControllerGroup()
//        self.mLightController = LightsController()
        
        
        
        if #available(iOS 9.0, *) {
            // iOS9. One year later things are OK.
            self.wk.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
        } else {
            // iOS8. Things can be workaround-ed
            //   Brave people can do just this
            //   fileURL = try! pathForBuggyWKWebView8(fileURL)
            //   webView.loadRequest(NSURLRequest(URL: fileURL))
            do {
                fileURL = try fileURLForBuggyWKWebView8(fileURL)
                self.wk.load(URLRequest(url: fileURL))
            } catch let error as NSError {
                print("Error: " + error.debugDescription)
            }
        }
        
        //        self.wk.loadRequest(NSURLRequest(URL:NSURL(string:"assets/index.html")!)) //临时取消
        
        self.view.addSubview(self.wk);
    }
    //将文件copy到tmp目录
    func fileURLForBuggyWKWebView8(_ fileURL: URL) throws -> URL {
        // Some safety checks
        var error:NSError? = nil;
        if (!fileURL.isFileURL || !(fileURL as NSURL).checkResourceIsReachableAndReturnError(&error)) {
            throw error ?? NSError(
                domain: "BuggyWKWebViewDomain",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("URL must be a file URL.", comment:"")])
        }
        
        // Create "/temp/www" directory
        let fm = FileManager.default
        let tmpDirURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("www")
        try! fm.createDirectory(at: tmpDirURL, withIntermediateDirectories: true, attributes: nil)
        
        // Now copy given file to the temp directory
        let dstURL = tmpDirURL.appendingPathComponent(fileURL.lastPathComponent)
        let _ = try? fm.removeItem(at: dstURL)
        try! fm.copyItem(at: fileURL, to: dstURL)
        
        // Files in "/temp/www" load flawlesly :)
        return dstURL
    }
    
    
}
private typealias wkScriptMessageHandler = ViewController
extension wkScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name)
        print((message.body as AnyObject).description)
        jb.handleJs(msg: message, controller: mUdpController)
//        mUdpController.startSendQueue()
//        mUdpController.searchDevice()
//        let data=mLightController.setManual(2, level: 70)
//        mUdpController.putCodeToQueue(code: data)
        
        
        
//        for i in 1 ... 1000 {
//            print("wait")
//            Thread.sleep(forTimeInterval: 0.2)
//        }

//        mUdpController.send(message:"www.usr.cn",ip:"255.255.255.255",port:48899)
    }
}
private typealias wkNavigationDegate = ViewController
extension WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.debugDescription)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.debugDescription)
    }
}
private typealias wkUIDelegate = ViewController
extension wkUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let ac = UIAlertController(title: webView.title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        ac.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (aa) -> Void in
            completionHandler()
        }))
        self.present(ac, animated: true, completion: nil)
    }
}





//import WebKit
//
//var wk: WKWebView!
//
//override func viewDidLoad(){
//    super.viewDidLoad()
//}


