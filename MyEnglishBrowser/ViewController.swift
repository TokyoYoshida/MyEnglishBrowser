//
//  ViewController.swift
//  MyEnglishBrowser
//
//  Created by TokyoMac on 2016/03/06.
//  Copyright © 2016年 TokyoMac. All rights reserved.
//
//

import UIKit
import WebKit
import Foundation
import MisterFusion
import RxSwift
import RxCocoa

class ViewController: UIViewController{
    @IBOutlet weak var naviBar: UIToolbar!
    @IBOutlet weak var address: UITextField!
    var webMainView: WKWebView!
    var viewModel: DictResultViewModel!
    var dictView: UITextView!
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeViewModel()
        makeView()
    }

    func makeViewModel(){
        viewModel = DictResultViewModel()
    }
    
    func makeView(){
        do {
            let bundle = NSBundle.mainBundle()
            let path = bundle.pathForResource("jquery.min", ofType: "js")
            let jsString = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding )
            
            let jsScript = WKUserScript(source: jsString, injectionTime: WKUserScriptInjectionTime.AtDocumentStart, forMainFrameOnly: true)
            
            let path2 = bundle.pathForResource("script", ofType: "js")
            let jsString2 = try String(contentsOfFile: path2!, encoding: NSUTF8StringEncoding )
            
            let jsScript2 = WKUserScript(source: jsString2, injectionTime: WKUserScriptInjectionTime.AtDocumentStart, forMainFrameOnly: true)
            
            let wkContentController = WKUserContentController();
            let wkConfiguration = WKWebViewConfiguration()
            wkConfiguration.userContentController = wkContentController
            
            let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
            let userController:WKUserContentController = WKUserContentController()
            
            userController.addUserScript(jsScript)
            userController.addUserScript(jsScript2)
            userController.addScriptMessageHandler(self, name: "callbackHandler")
            webCfg.userContentController = userController;
            
            webMainView = WKWebView(
                frame: CGRectMake(100, 100, self.view.frame.size.width/2, self.view.frame.size.height/2),configuration: webCfg)
            
            self.view.addLayoutSubview(webMainView ,andConstraints:
                webMainView.Top    |==| naviBar.Bottom,
                                       webMainView.Right  |-| 0,
                                       webMainView.Left   |+| 0,
                                       webMainView.Bottom |==| self.view.Bottom |*| 0.8 |-| 0
            )
            
            let url = NSURL(string:"http://google.co.jp/")
            let req = NSURLRequest(URL:url!)
            self.webMainView.loadRequest(req)
            
//            webDictView = WKWebView(
//                frame: CGRectMake(100, 300, self.view.frame.size.width/2, self.view.frame.size.height/2),configuration: WKWebViewConfiguration())
//            self.view.addLayoutSubview(webDictView,andConstraints:
//                webDictView.Top    |==| webMainView.Bottom,
//                                       webDictView.Right  |-| 0,
//                                       webDictView.Left   |+| 0,
//                                       webDictView.Bottom |-| 0
//            )
//            
//            self.webDictView.loadRequest(NSURLRequest(URL:NSURL(string:"http://google.co.jp")!))
            
            
        } catch {
            print ("error")
        }
    }
    
}

extension ViewController: WKNavigationDelegate  {
    @IBAction func playOnClick(sender: UIBarButtonItem) {
        address.resignFirstResponder()
        if let url = NSURL(string: address.text!) {
            webMainView.loadRequest(NSURLRequest(URL: url))
        }
        return
    }
    @IBAction func rewindClick(sender: AnyObject) {
        webMainView.goBack()
    }
}

extension ViewController: WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        guard message.name == "callbackHandler" else {
            return
        }
        print("JavaScript is sending a message \(message.body)")
        viewModel.search_word.onNext(String(message.body))
//        viewModel.search_word.onCompleted()
    }
}


