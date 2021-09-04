//
//  PaygateVC.swift
//  Goteso Food
//
//  Created by IOS on 08/06/20.
//  Copyright © 2020 Kishore. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD

protocol WebViewResponseDelegate {
    func response(url:String)
}



class PaygateVC: UIViewController {

    var webViewResponseDelegate : WebViewResponseDelegate!
   
    var jsonString = "http://192.168.1.22/laravel/laravel/Payment_Gateways/PayGate/public/pay"
    var dataDictionary = NSDictionary.init()
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var webV: WKWebView!
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
     print(dataDictionary)

        webV.navigationDelegate = self
               webV.uiDelegate = self
            //   SVProgressHUD.show()
               webV.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        if COMMON_FUNCTIONS.checkForNull(string: dataDictionary["payment_page"] as AnyObject).1 != "" {
            webV.load(URLRequest(url: URL(string: dataDictionary["payment_page"] as! String)!))
//            webV.loadHTMLString(dataDictionary["payment_page"] as! String, baseURL: nil)
        }
    }
    
}

extension PaygateVC : WKUIDelegate,  WKNavigationDelegate
{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
       SVProgressHUD.dismiss()
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()", completionHandler: ({ (jsonRaw: Any?, error: Error?) in
            
            if let text = webView.url?.absoluteString {
                   print(text)
            if text == self.dataDictionary["listen_page"] as! String {
                self.webViewResponseDelegate.response(url: self.dataDictionary["confirm_url"] as! String)
                 self.dismiss(animated: false, completion: nil)
            }
            }
      
           }))
        
        SVProgressHUD.dismiss()
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return [:]
    }

    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        SVProgressHUD.show()
        if navigationAction.targetFrame!.isMainFrame {
                   decisionHandler(.allow)

               } else {
                   decisionHandler(.allow)
               }
       }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            print("Observer is Called.")
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return webView
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        if navigationResponse.isForMainFrame {
            decisionHandler(.allow)

        } else {
            decisionHandler(.allow)
        }
        
        let response = (navigationResponse.response as! HTTPURLResponse)
        print(response)
        print("Status Code == \( response.statusCode )")

        print(response)
        print(response.allHeaderFields)
        print(webView.url?.host!)
        print(response.statusCode)
    

    }
    
//    func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
//        SVProgressHUD.show()
//        return true
//    }
      
}

