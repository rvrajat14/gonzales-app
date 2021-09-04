//
//  MyAPIClient.swift
//  Car Wash
//
//  Created by Kishore on 23/01/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import Foundation
import Stripe
import Alamofire
import SwiftyJSON

class MyAPIClient: NSObject, STPEphemeralKeyProvider {
    
    static let sharedClient = MyAPIClient()
    var user_id = ""
    
    var baseURLString: String? = BASE_URL
    var baseURL: URL {
        if let urlString = self.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError("Index Is Invalid")
        }
    }
    
    func completeCharge(_ result: STPPaymentResult,
                        amount: Int,currency:String,
                        shippingAddress: STPAddress?,
                        shippingMethod: PKShippingMethod?,
                        completion: @escaping STPErrorBlock,success:@escaping (_ response:NSDictionary) -> ()) {
        let url = self.baseURL.appendingPathComponent(APINAME().STRIPE_PAYMENT_API)
        let params: [String: Any] = [
            "token": result.paymentMethod?.stripeId as Any,
            "amount": amount,"currency":currency,"customer_id":user_id
            ]
        do{
            let body = try JSONSerialization.data(withJSONObject: params , options: .prettyPrinted)
            
            let postString = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
            
            print("Post Data -> \(String(describing: postString))")
        }
        catch
        {
            
        }
        WebService.authenticationFunction(isForLogin: false)
        
        let headers = [
            
            "timezone":localTimeZoneName,
            "Accept": "application/json",
            "Authorization": "\(token_type) \(access_token)"
        ]
        print(headers)
        
        Alamofire.request(url, method:  .post, parameters:  params, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    success(JSON(response.data!).dictionaryObject! as NSDictionary)
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent(APINAME().EPHEMERAL_KEYS_API)
        print(url)
        let param  = [
            "api_version": stripe_api_version,"customer_id":user_id
        ]
        
        do{
            
        let body = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
        
        let postString = NSString(data: body, encoding: String.Encoding.utf8.rawValue)
        
        print("Post Data -> \(String(describing: postString))")
        }
        catch
        {
            
        }
        
        WebService.authenticationFunction(isForLogin: false)
        
        let headers = [
           
            "timezone":localTimeZoneName,
            "Accept": "application/json",
            "Authorization": "\(token_type) \(access_token)"
        ]
        print(headers)
        
        Alamofire.request(url, method:  .post, parameters:  param, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
}
