//
//  WebService.swift
//  Dry Clean City
//
//  Created by Apple on 06/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD


class WebService: NSObject {

    
    class func showAlert ()
    {
        let alert = UIAlertController(title: nil, message: " \n\n\n\n\n\n\n", preferredStyle: .alert)
        let uiView = UIView(frame: CGRect(x: alert.view.frame.origin.x, y: 15, width: 250, height: 150))
      
        let imageV = UIImageView(frame: CGRect(x: uiView.center.x - 40, y: 10, width: 100, height: 90))
        
        imageV.image = #imageLiteral(resourceName: "internet-placeholder")
        imageV.contentMode = .scaleAspectFill
        uiView.addSubview(imageV)
        let msgLbl = UILabel(frame: CGRect(x: uiView.frame.origin.x + 20, y: imageV.frame.size.height + 30, width: 230, height: 50))
        msgLbl.font = UIFont(name: REGULAR_FONT, size: 17)
        msgLbl.textAlignment = .center
        msgLbl.numberOfLines = 2
        msgLbl.textColor = UIColor(red: 108/255.0, green: 108/255.0, blue: 108/255.0, alpha: 1)
        msgLbl.text = "Check the Internet connection"
        let fonD:UIFontDescriptor = msgLbl.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
        
        msgLbl.font = UIFont(descriptor: fonD, size: 17)
        uiView.addSubview(msgLbl)
        alert.view.addSubview(uiView)
        
        alert.addAction(UIAlertAction(title: "z_ok".getLocalizedValue(), style: .default, handler: { (action) in
           return
        }))
        let viewController = UIApplication.shared.keyWindow?.rootViewController
        
        let popPresenter = alert.popoverPresentationController
        popPresenter?.sourceView = viewController?.view
        popPresenter?.sourceRect = (viewController?.view.bounds)!
        viewController?.present(alert, animated: true, completion: nil)
    }
    
  
    class func requestGetUrlForCheckPort(strURL:String,is_loader_required:Bool, success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
        
        
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            if is_loader_required
            {
                SVProgressHUD .show()
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.setRingNoTextRadius(14.0)
            }
            
            
            if is_loader_required
            {
                SVProgressHUD .show()
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.setRingNoTextRadius(14.0)
            }
            
            do
            {
                // json format
                let body = try JSONSerialization.data(withJSONObject: [:], options: .prettyPrinted)
                
                let postString = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
                
                print("Post Data -> \(String(describing: postString))")
                
            }
            catch let error as NSError
            {
                print(error)
            }
            
            authenticationFunction(isForLogin: false)
            
            
            let headers = [
             
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
                
            ]
            print(headers)
            var  BaseUrl = ""
            if url_type == "port"
            {
                BaseUrl = BASE_URL 
                // BaseUrl = "http://139.59.86.194:4105/v2/"
            }
            else
            {
                BaseUrl = "https://www.ordefy.com/api/"
            }
            
            
            var request = URLRequest(url: NSURL(string: BaseUrl.appending(strURL))! as URL)
            print(BaseUrl.appending(strURL))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            
            Alamofire.request(request)
                .responseString { response in
                    // do whatever you want here
                    switch response.result {
                    case .success(_):
                        if let data = response.data
                        {
                            //Check for "Unauthenticated access"
                            SVProgressHUD.dismiss()
                            if let dataDictionary = JSON(data).dictionaryObject
                            {
                                if let status = ((dataDictionary as NSDictionary)["status_code"] as? NSNumber)
                                {
                                    if status == 1001{
                                        NotificationCenter.default.post(name: NSNotification.Name.init("LogoutNotification"), object: nil)
                                        return
                                    }
                                    
                                    
                                }
                            }
                            
                            
                            if let dataDictionary = JSON(data).dictionaryObject
                            {
                                
                                if dataDictionary["status_code"] == nil
                                {
                                    success(NSDictionary(dictionaryLiteral: ("status_code",1008),("message","")))
                                }
                                else
                                {
                                    success(dataDictionary as NSDictionary)
                                }
                            }
                            if let dataArray = JSON(data).arrayObject
                            {
                                success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                            }
                            else
                            {
                                
                            }
                        }
                        break
                        
                    case .failure(_):
                        SVProgressHUD.dismiss()
                        print(response.error as Any)
                        let viewController = UIApplication.shared.keyWindow?.rootViewController
                        viewController?.view.makeToast(response.error?.localizedDescription, duration: 1.0, position: .bottom)
                        failure(response.error.debugDescription )
                        break
                    }
            }
        }
            
        else
        {
            showAlert()
            return
        }
        
    }
    
    
    
    class func requestGetUrl(strURL:String, params:NSDictionary,is_loader_required:Bool, success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
        
        
        
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
        
            if is_loader_required
            {
                SVProgressHUD .show()
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.setRingNoTextRadius(14.0)
            }
           
        print(BASE_URL.appending(strURL))
            
              authenticationFunction(isForLogin: false)
            
            
            let headers = [
                "class_identifier": app_type,
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
                
            ]
            print(headers)
            
            var request = URLRequest(url: NSURL(string: BASE_URL.appending(strURL).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)! as URL)
            print(BASE_URL.appending(strURL))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            
            Alamofire.request(request)
                .responseString { response in
                    
                    // do whatever you want here
                    switch response.result {
                    case .success(_):
                        if let data = response.data
                        {
                            print(JSON(data))
                            SVProgressHUD.dismiss()
                            //Check for "Unauthenticated access"
                            if let dataDictionary = JSON(data).dictionaryObject
                            {
                                if let status = ((dataDictionary as NSDictionary)["status_code"] as? NSNumber)
                                {
                                    if status == 1001{
                                        NotificationCenter.default.post(name: NSNotification.Name.init("LogoutNotification"), object: nil)
                                        return
                                    }
                                    
                                    
                                }
                            }
                            
                            
                            if let dataDictionary = JSON(data).dictionaryObject
                            {
                                if dataDictionary["status_code"] == nil
                                {
                                    success(NSDictionary(dictionaryLiteral: ("status_code",1008),("message","")))
                                }
                                else
                                {
                                    success(dataDictionary as NSDictionary)
                                }
                            }
                            if let dataArray = JSON(data).arrayObject
                            {
                                success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                            }
                        }
                        break
                        
                    case .failure(_):
                        SVProgressHUD.dismiss()
                        failure(response.error.debugDescription )
                        print(response.error.debugDescription)
                        break
                    }
            }
            
        }
            
        else
        {
            showAlert()
            return
        }
    }
    
    
    
    
    class func requestPostUrl(strURL:String, params:NSDictionary,is_loader_required:Bool, success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
        
        
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
        
        
            if is_loader_required
            {
                SVProgressHUD .show()
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.setRingNoTextRadius(14.0)
            }
        
            do
            {
                // json format
                let body = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                
                let postString = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
                
                print("Post Data -> \(String(describing: postString))")
                
            }
            catch let error as NSError
            {
                print(error)
            }
            
            
            if !strURL.contains("oauth/token")
            {
                 authenticationFunction(isForLogin: false)
                
            }
           
            
            let headers = [
                "class_identifier": app_type,
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
                
            ]
            print(headers)
        print(BASE_URL.appending(strURL))
        Alamofire.request(BASE_URL.appending(strURL), method: HTTPMethod.post, parameters: params as? Parameters, encoding: JSONEncoding.default, headers: headers).responseData { (response:DataResponse<Data>) in
      

            switch(response.result) {
            case .success(_):
                if let data = response.data
                {
                     SVProgressHUD.dismiss()
                    
                    //Check for "Unauthenticated access"
                    if let dataDictionary = JSON(data).dictionaryObject
                    {
                        if let status = ((dataDictionary as NSDictionary)["status_code"] as? NSNumber)
                        {
                            if status == 1001{
                                NotificationCenter.default.post(name: NSNotification.Name.init("LogoutNotification"), object: nil)
                                return
                            }
                            
                            
                        }
                    }
                    
                    
                    if let dataDictionary = JSON(data).dictionaryObject
                    {
                        if strURL.contains("oauth/token")
                        {
                            success(dataDictionary as NSDictionary)
                        }
                        else
                        {
                            if dataDictionary["status_code"] == nil
                            {
                                success(NSDictionary(dictionaryLiteral: ("status_code",1008),("message","")))
                            }
                            else
                            {
                                success(dataDictionary as NSDictionary)
                            }
                        }
                    }
                    if let dataArray = JSON(data).arrayObject
                    {
                        success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                    }
                   
                }
                break
                
            case .failure(_):
                 SVProgressHUD.dismiss()
                failure(response.error.debugDescription )
                break
            }
            
            
        }
        }
            
        else
        {
            showAlert()
            return
        }
    }
    
    
    
    class func requestDelUrl(strURL:String,is_loader_required:Bool, success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
        
        
        
        
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
          
            if is_loader_required
            {
                SVProgressHUD .show()
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.setRingNoTextRadius(14.0)
            }
        
            
        
        print(BASE_URL.appending(strURL))
            
              authenticationFunction(isForLogin: false)
            
            let headers = [
                "class_identifier": app_type,
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
                
            ]
            print(headers)
            
        Alamofire.request(BASE_URL.appending(strURL), method: HTTPMethod.delete, parameters: [:], encoding: JSONEncoding.default, headers: headers).responseData { (response:DataResponse<Data>) in
            
            switch(response.result) {
            case .success(_):
                if let data = response.data
                {
                    print(data)
                    SVProgressHUD.dismiss()
                    
                    //Check for "Unauthenticated access"
                    if let dataDictionary = JSON(data).dictionaryObject
                    {
                        if let status = ((dataDictionary as NSDictionary)["status_code"] as? NSNumber)
                        {
                            if status == 1001{
                                NotificationCenter.default.post(name: NSNotification.Name.init("LogoutNotification"), object: nil)
                                return
                            }
                            
                            
                        }
                    }
                    
                    
                    if let dataDictionary = JSON(data).dictionaryObject
                    {
                        if dataDictionary["status_code"] == nil
                        {
                            success(NSDictionary(dictionaryLiteral: ("status_code",1008),("message","")))
                        }
                        else
                        {
                            success(dataDictionary as NSDictionary)
                        }
                    }
                    if let dataArray = JSON(data).arrayObject
                    {
                        success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                    }
                    
                }
                break
                
            case .failure(_):
                SVProgressHUD.dismiss()
                failure(response.error.debugDescription )
                break
            }
            
        }
        }
            
        else
        {
            showAlert()
            return
        }
        
    }
    
    
    class func authenticationFunction(isForLogin:Bool)
    {
    
        
        if isForLogin {
            return
        }
        
        if  UserDefaults.standard.value(forKey: "expireDate") != nil
        {
            let currentDate = Date()
            let expireDate = (UserDefaults.standard.value(forKey: "expireDate") as! Date)
            
            if UserDefaults.standard.value(forKey: "refresh_token") != nil
            {
                refresh_token = (UserDefaults.standard.value(forKey: "refresh_token") as! String)
            }
            if currentDate > expireDate
            {
               
                        let api_name = APINAME().ACCESS_TOKEN_API
                        let param = ["grant_type":"refresh_token","client_secret":"f36F4ZZN84kWE9cwYbFj2Y6er5geY9OBXF3hEQO4","client_id":"2","refresh_token":refresh_token]
                        
                        var request = URLRequest(url: NSURL(string: BASE_URL.appending(api_name))! as URL)
                        print(BASE_URL.appending(api_name))
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        request.httpMethod = "POST"
                        
                        do
                        {
                            // json format
                            let body = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                            
                            let postString = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
                            
                            print("Post Data -> \(String(describing: postString))")
                            
                            request.httpBody = body
                            
                        }
                        catch let error as NSError
                        {
                            print(error)
                        }
                        
                        
                        var response: URLResponse?
                         var resultDictionary: NSDictionary!
                        do
                        {
                           let urlData = try NSURLConnection.sendSynchronousRequest(request, returning: &response)
                            resultDictionary = try (JSONSerialization.jsonObject(with: urlData, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary)
                            print(resultDictionary)
                            
                            if resultDictionary["error"] != nil
                            {
                                  NotificationCenter.default.post(name: NSNotification.Name.init("LogoutNotification"), object: nil)
                             return
                            }
                            else
                            {
                                access_token = (resultDictionary["access_token"] as! String)
                                refresh_token = (resultDictionary["refresh_token"] as! String)
                                token_type  = (resultDictionary["token_type"] as! String)
                                let expireTime = (resultDictionary["expires_in"] as! NSNumber)
                                let expireDate = Date().addingTimeInterval(TimeInterval(exactly: expireTime)!)
                                UserDefaults.standard.setValue(access_token, forKey: "access_token")
                                UserDefaults.standard.setValue(expireDate, forKey: "expireDate")
                                UserDefaults.standard.setValue(refresh_token, forKey: "refresh_token")
                                UserDefaults.standard.setValue(token_type, forKey: "token_type")
                                 return
                            }
                            
                        
                        }
                        catch
                        {
                            
                        }
                        
                
            }
        }
         return
    }
    
    
    class func requestPostUrlWithJSONDictionaryParameters(strURL:String,is_loader_required:Bool, params:[String:Any], success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
      
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            
            
            if is_loader_required
            {
                SVProgressHUD .show()
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.setRingNoTextRadius(14.0)
            }
        
        print(BASE_URL.appending(strURL))
        print(params )
       
        do
        {
            // json format
            let body = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            let postString = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
            
            print("Post Data -> \(String(describing: postString))")
            
        }
        catch let error as NSError
        {
            print(error)
        }
            var isForLogin = false
            
            if strURL.contains("user-login")
            {
               isForLogin = true
            }
            else
            {
                isForLogin = false
            }
            
         if !strURL.contains("user-login")
         {
             authenticationFunction(isForLogin: isForLogin)
           
            }
            
            let headers = [
                "class_identifier": app_type,
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
                
            ]
            print(headers)
            
        Alamofire.request(BASE_URL.appending(strURL), method: HTTPMethod.post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { (response:DataResponse<Data>) in
            
            
            switch(response.result) {
            case .success(_):
                if let data = response.data
                {
                    print(JSON(data))
                     SVProgressHUD.dismiss()
                    
                    //Check for "Unauthenticated access"
                    if let dataDictionary = JSON(data).dictionaryObject
                    {
                        if let status = ((dataDictionary as NSDictionary)["status_code"] as? NSNumber)
                        {
                            if status == 1001{
                                NotificationCenter.default.post(name: NSNotification.Name.init("LogoutNotification"), object: nil)
                                return
                            }
                            
                            
                        }
                    }
                    
                    
                    if let dataDictionary = JSON(data).dictionaryObject
                    {
                        if dataDictionary["status_code"] == nil
                        {
                            success(NSDictionary(dictionaryLiteral: ("status_code",1008),("message","")))
                        }
                        else
                        {
                            success(dataDictionary as NSDictionary)
                        }
                    }
                    if let dataArray = JSON(data).arrayObject
                    {
                        success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                    }
                }
                break
                
            case .failure(_):
                 SVProgressHUD.dismiss()
                failure(response.error.debugDescription )
                break
            }
            
            
        }
        }
            
        else
        {
            showAlert()
            return
        }
    }
    
    
    
    
    class func requestPUTUrlWithJSONArrayParameters(strURL:String,is_loader_required:Bool, params:NSArray, success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
        
        
        
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            
        
            if is_loader_required
            {
                SVProgressHUD .show()
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.setRingNoTextRadius(14.0)
            }
        
         print(BASE_URL.appending(strURL))
            
             authenticationFunction(isForLogin: false)
            
            
            let headers = [
                "class_identifier": app_type,
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
                
            ]
            print(headers)
            
        var request = URLRequest(url: NSURL(string: BASE_URL.appending(strURL))! as URL)
        print(BASE_URL.appending(strURL))
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = headers
        do
        {
            // json format
                let body = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                
                let postString = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
                
                print("Post Data -> \(String(describing: postString))")
                
                request.httpBody = body
           
        }
        catch let error as NSError
        {
            print(error)
        }
        
          
           
            
        Alamofire.request(request)
            .responseString { response in
               
                
                // do whatever you want here
                switch response.result {
                case .success(_):
                    if let data = response.data
                    {
                        print(JSON(data))
                         SVProgressHUD.dismiss()
                        
                        //Check for "Unauthenticated access"
                        if let dataDictionary = JSON(data).dictionaryObject
                        {
                            if let status = ((dataDictionary as NSDictionary)["status_code"] as? NSNumber)
                            {
                                if status == 1001{
                                    NotificationCenter.default.post(name: NSNotification.Name.init("LogoutNotification"), object: nil)
                                    return
                                }
                                
                                
                            }
                        }
                        
                        
                        if let dataDictionary = JSON(data).dictionaryObject
                        {
                            if dataDictionary["status_code"] == nil
                            {
                                success(NSDictionary(dictionaryLiteral: ("status_code",1008),("message","")))
                            }
                            else
                            {
                                success(dataDictionary as NSDictionary)
                            }
                        }
                        if let dataArray = JSON(data).arrayObject
                        {
                            success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                        }
                    }
                    break
                    
                case .failure(_):
                     SVProgressHUD.dismiss()
                    failure(response.error.debugDescription )
                     print(response.error.debugDescription)
                    break
                }
        }
        }
            
        else
        {
            showAlert()
            return
        }
    }
    
    
    
    class func requestPUTUrlWithJSONDictionaryParameters(strURL:String,is_loader_required:Bool, params:[String:Any], success:@escaping (_ response:NSDictionary) -> (), failure:@escaping (String) -> ()) {
        
        
        if Connectivity.isConnectedToInternet {
            print("Yes! internet is available.")
            
            
            if is_loader_required
            {
                SVProgressHUD .show()
                SVProgressHUD.setDefaultStyle(.custom)
                SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black)
                SVProgressHUD.setRingNoTextRadius(14.0)
            }
        
        print(BASE_URL.appending(strURL))
        print(params )
        
            var request = URLRequest(url: NSURL(string: BASE_URL.appending(strURL))! as URL)
            print(BASE_URL.appending(strURL))
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "PUT"
            
            do
            {
                // json format
                let body = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                
                let postString = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
                
                print("Post Data -> \(String(describing: postString))")
                
                request.httpBody = body
                
            }
            catch let error as NSError
            {
                print(error)
            }
            
             authenticationFunction(isForLogin: false)
            
            
            let headers = [
                "class_identifier": app_type,
                "timezone":localTimeZoneName,
                //"Content-Type": "application/json",
                "Accept": "application/json",
                "Authorization": "\(token_type) \(access_token)"
                
            ]
            print(headers)
            
        Alamofire.request(BASE_URL.appending(strURL), method: HTTPMethod.put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseData { (response:DataResponse<Data>) in
            
            
            
            switch(response.result) {
            case .success(_):
                if let data = response.data
                {
                    print(JSON(data))
                    SVProgressHUD.dismiss()
                    
                    //Check for "Unauthenticated access"
                    if let dataDictionary = JSON(data).dictionaryObject
                    {
                        if let status = ((dataDictionary as NSDictionary)["status_code"] as? NSNumber)
                        {
                            if status == 1001{
                                NotificationCenter.default.post(name: NSNotification.Name.init("LogoutNotification"), object: nil)
                                return
                            }
                            
                            
                        }
                    }
                    
                    
                    if let dataDictionary = JSON(data).dictionaryObject
                    {
                        if dataDictionary["status_code"] == nil
                        {
                            success(NSDictionary(dictionaryLiteral: ("status_code",1008),("message","")))
                        }
                        else
                        {
                            success(dataDictionary as NSDictionary)
                        }
                    }
                    if let dataArray = JSON(data).arrayObject
                    {
                        success(NSDictionary(dictionaryLiteral:  ("data",dataArray)))
                    }
                }
                break
                
            case .failure(_):
                SVProgressHUD.dismiss()
                failure(response.error.debugDescription )
                break
            }
            
            
        }
        }
            
        else
        {
            showAlert()
            return
        }
    }

}

class APINAME {
 
    
    //Category API
    let CATEGORY_API = prefix + "product/categories" //Done
    
    let STORES_API = prefix + "stores"
    
    let ITEM_VARIANT =  prefix + "product-variant" //Done
    
    let AREA_API = prefix + "areas"
    
    let PENDING_PAYMENT = prefix + "pending-payment"
    
    let ADDRESS_API = prefix + "address" //Done
    
    let GET_COUPONS_LIST = prefix + "coupons"
    
    let ORDERS_API = prefix + "orders"
    
    let LOGIN_API = prefix + "login"
    
    let LOGOUT = prefix + "logout"
    let USER_API = prefix + "me"
    //Change Password
    let UPDATE_PASSWORD = prefix + "update-password" //Done
    //Reset Password
    let FORGOT_PASSWORD = prefix + "forgot-password" //Done
    let VERIFY_OTP = prefix + "forgot-password/verify" //Done
    let RESET_PASSWORD = prefix + "reset-password" //Done
    let USER_FORM_API = prefix + "profile/form"
    let GET_ORDER_FORM = prefix + "order/form"
    let PLACE_ORDER_CALCULATE = prefix + "order/payment-summary"
    let CART_SUMMARY_API = prefix + "order/cart-summary"

    let GET_TIME_SLOTS_LIST = prefix + "order/timeslots"
    let ITEM_API = prefix + "products"
    let BANNERS_API = prefix + "store/banners"
    let SETTINGS_API = prefix + "settings"
    let SOCIAL_MEDIA_SETTINGS = prefix + "setting/social"
    
    let ORDER_REVIEW_API = prefix + "order/review"
    let GET_REVIEW_LIST = prefix + "reviews"
    let GET_DRIVER_LOCATION = prefix + "order/driver"
    let CHATTING_API = prefix + "order/messages"
    let ORDER_CANCEL = prefix + "order/cancel"
    let GET_PAYMENT_GATEWAYS = prefix + "payment-gateway"
    let COUPON_API = prefix + "order/apply-coupon"
    let STORE_FILTER = prefix + "store/filters"
    let WALLET_API = prefix + "wallet"
    let POINTS_API = prefix + "order/points"
    let FAQ_API =  prefix + "faq" //Done
    let ACCESS_TOKEN_API = "oauth/token"
     let CHECK_TEAM = "check_team" //Done
    
    
    let SIGNUP_OTP_API = prefix + "signup-otp"
    let SIGNUP_API = prefix + "signup"
    
    let INVITE_CODE = prefix + "user-codes"
    let GET_APP_DETAILS = prefix + "info/customer"
    
    
    let STRIPE_PAYMENT_API = prefix + "pg/stripe/checkout"
    
    let CREATE_RAZORPAY_ORDER = prefix +  "pg/razorpay"
    let EPHEMERAL_KEYS_API = prefix + "pg/stripe"
    
   
    let PG_PAYTM_API = prefix + "pg/paytm"
    let PAYTM_SUMHASH_MATCHING_API = prefix + "pg/paytm/match"
    
     let SOCIAL_LOGIN_API = prefix + "social-login"
    
}


class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}
