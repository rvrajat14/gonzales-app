//
//  CommonPaymentHandler.swift
//  Go Courier
//
//  Created by Apple on 26/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit
import Stripe
import Alamofire
import SVProgressHUD
import SwiftyJSON
import Razorpay
//import PaymentSDK
import WebKit


enum PayPalEnvironmentType {
    case PayPalEnvironmentProduction
    case PayPalEnvironmentSandbox
    case PayPalEnvironmentNoNetwork
}


protocol CommonPaymentHandlerProtocol {
    
    func paymentFailed(errorMsg:String)
    func paymentDone(transactionId:String)
    
}

protocol PaytmProtocol {
    func patymPaymentDone(transactionId:String)
}

class CommonPaymentHandler: NSObject {
 
   
    static let paymentHandlerSharedInstance  = CommonPaymentHandler()
    var commonPaymentHandlerDelegate : CommonPaymentHandlerProtocol!
    var patymProtocolDelegate : PaytmProtocol!
   
    private var apiOBJ : MyAPIClient!
    // Controllers
    private var customerContext: STPCustomerContext!
    private var razorpay:RazorpayCheckout?
//    private var payPalConfig = PayPalConfiguration()
//    private var payment : PayPalPayment!
    var paymentBasicRequirement = (user_id:"",amount: "", currency: "",currentlyVC:UIViewController())
    var paytmBasicRequirement = (user_id:"",orderId:"",amount:"",currentlyVC:UIViewController())
    private var transactionId = ""
    
//    private var serverEnv : PGServerEnvironment!
       
    
    func setPaymentMethodEnvironment(with data: NSDictionary)  {
        if data["identifier"] as! String == "stripe" {
           setStripePaymentEnvironment(dataDic: (data["data"] as! NSDictionary))
        }
        
        if data["identifier"] as! String == "paypal" {
//           setPayPalEnvirontment(dataDic: (data["data"] as! NSDictionary))
        }
    }
    
    
    //MARK: Set Stripe Payment Environment
    
    func setStripePaymentEnvironment(dataDic:NSDictionary)  {
        
        paymentBasicRequirement.currency = (dataDic["currency_code"] as! String)
        STPPaymentConfiguration.shared().publishableKey = (dataDic["publishable_key"] as! String)
        
        apiOBJ = MyAPIClient.sharedClient
        apiOBJ.user_id = paymentBasicRequirement.user_id
        SVProgressHUD.show()
        //Create Customer Key
        apiOBJ.createCustomerKey(withAPIVersion: stripe_api_version) { (response, error) in
            
            if error != nil
            {
                print(error!)
            }
            else
            {
                print(response!)
            }
            SVProgressHUD.dismiss()
        }
        customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
        
       // if paymentContext1 == nil {
             paymentContext1 = STPPaymentContext(customerContext: customerContext)
      //  }
        
       
        paymentContext1!.paymentAmount = Int(Float(paymentBasicRequirement.amount)! * 100)
        paymentContext1!.delegate = self
        paymentContext1!.hostViewController = paymentBasicRequirement.currentlyVC
        
    }
    
    func setStripeCartView()  {
        paymentContext1?.presentPaymentOptionsViewController()
    }
    
    func pushStripeVCForPayment()  {
        paymentContext1?.requestPayment()
    }
    
  ///////////////////////////////////////       //////////////////////////////////////////////////////////////////
    
 
    //MARK: Set PayPal Environment
    
//    func setPayPalEnvirontment(dataDic:NSDictionary)  {
//        paymentBasicRequirement.currency = (dataDic["currency_code"] as! String)
//        payPalConfig.merchantName = (Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String)
//        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.goteso.com")
//        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.goteso.com")
//        if dataDic["type"] as! String == "LIVE" {
//            PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: " "])
//            PayPalMobile.preconnect(withEnvironment: PayPalEnvironmentProduction)
//
//        }
//        else if dataDic["type"] as! String == "SANDBOX"
//        {
//            PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentSandbox:" "])
//            PayPalMobile.preconnect(withEnvironment: PayPalEnvironmentSandbox)
//
//        }
//        else
//        {
//
//
//        }
//
//    }
    
    
    //MARK: Paypal Payment
//    func pushPaypalPaymentVC()  {
//
//        let amount = NSDecimalNumber(string: COMMON_FUNCTIONS.getCorrectPriceFormat(price:  COMMON_FUNCTIONS.checkForNull(string: paymentBasicRequirement.amount as AnyObject).1))
//
//        payment = PayPalPayment(amount: amount , currencyCode: paymentBasicRequirement.currency, shortDescription: " ", intent: .sale)
//        if (payment.processable) {
//            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
//
//           paymentBasicRequirement.currentlyVC.present(paymentViewController!, animated: true, completion: nil)
//        }
//
//    }
    
    //////////////////////??????????////////////////????????////////??????/////?????/
    
    
     //MARK: Set Razorpay Environment
    
    
    func setRazorpayEnvironment(data:NSDictionary)  {
        
         razorpay = RazorpayCheckout.initWithKey("", andDelegate: self)
    }
    
    // Get razorPayId
    func pushRazorpayPaymentVC()  {
        let api_name =  APINAME().CREATE_RAZORPAY_ORDER
        
        let param = ["amount":paymentBasicRequirement.amount,"customer_id":paymentBasicRequirement.user_id]
        WebService.requestPostUrl(strURL: api_name, params: param as NSDictionary, is_loader_required: false, success: { (response) in
            print(response)
            if response["status_code"] as! NSNumber == 1
            {
                
                let order_id = COMMON_FUNCTIONS.checkForNull(string: ((response["data"] as! NSDictionary)["order_id"]) as AnyObject).1
                
                let amount = (Float(self.paymentBasicRequirement.amount)!) * 100
                
                let options: [String:Any] = [
                    "amount" : amount,//mandatory in paise like:- 1000 paise ==  10 rs
                    "description": "Our Service build smile",
                    "order_id": order_id,
                    "name": "SRAA3",
                    "prefill": [
                        "contact": "",
                        "email": ""
                    ],
                    "theme": [
                        "color": "#000000"
                    ]
                ]
                self.razorpay?.open(options)
            }
            else
            {
                self.commonPaymentHandlerDelegate.paymentFailed(errorMsg: (response["message"] as! String))
            }
        }) { (failure) in
            
        }
    }
    
    
    
    //MARK: Return to last VC  On Payment Done
    
   private func paymentDone()  {
        commonPaymentHandlerDelegate.paymentDone(transactionId: transactionId)
    }
    
    //MARK: Paytm Payment
          
//          func pushPaytmPaymentVC() {
//                  let api_name = APINAME.init().PG_PAYTM_API
//              let params = ["orderId":paytmBasicRequirement.orderId , "amount":paytmBasicRequirement.amount , "user_id":paytmBasicRequirement.user_id] as [String:Any]
//                  print(params)
//                  WebService.requestPostUrl(strURL: api_name, params: params as NSDictionary, is_loader_required: true, success: { (response) in
//                      print(response)
//                      if response["status_code"] as! NSNumber == 1 {
//
//                          let data_dic = ((response["data"] as! NSDictionary)["paytmParams"] as! NSDictionary)
//                          self.setupPaytm(MID: COMMON_FUNCTIONS.checkForNull(string: data_dic["MID"] as AnyObject).1, ORDER_ID: COMMON_FUNCTIONS.checkForNull(string: data_dic["ORDER_ID"] as AnyObject).1, CUST_ID: COMMON_FUNCTIONS.checkForNull(string: data_dic["CUST_ID"] as AnyObject).1, CHANNEL_ID: COMMON_FUNCTIONS.checkForNull(string: data_dic["CHANNEL_ID"] as AnyObject).1, INDUSTRY_TYPE_ID: COMMON_FUNCTIONS.checkForNull(string: data_dic["INDUSTRY_TYPE_ID"] as AnyObject).1, WEBSITE: COMMON_FUNCTIONS.checkForNull(string: data_dic["WEBSITE"] as AnyObject).1, TXN_AMOUNT: COMMON_FUNCTIONS.checkForNull(string: data_dic["TXN_AMOUNT"] as AnyObject).1, CHECKSUMHASH: COMMON_FUNCTIONS.checkForNull(string: (response["data"] as! NSDictionary)["paytmChecksum"] as AnyObject).1, CALLBACK_URL: COMMON_FUNCTIONS.checkForNull(string: data_dic["CALLBACK_URL"] as AnyObject).1, EMAIL: COMMON_FUNCTIONS.checkForNull(string: data_dic["EMAIL"] as AnyObject).1, MOBILE_NO: COMMON_FUNCTIONS.checkForNull(string: data_dic["MOBILE_NO"] as AnyObject).1)
//                      }
//                      else {
//
//                      }
//                  }) { (error) in
//                      print(error)
//                  }
//              }
    
  
}


extension CommonPaymentHandler: RazorpayPaymentCompletionProtocol {
    func onPaymentSuccess(_ payment_id: String) {
        print(payment_id)
       transactionId = payment_id
        paymentDone()
        /* let alert = UIAlertController(title: "Paid", message: "Payment Success", preferredStyle: .alert)
         let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
         alert.addAction(action)
         self.present(alert, animated: true, completion: nil) */
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        
        commonPaymentHandlerDelegate.paymentFailed(errorMsg: "\(code)\n\(str)")
      
    }
}



//extension CommonPaymentHandler : PayPalPaymentDelegate
//{
//    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
//        // COMMON_ALERT.showAlert(msg: "PayPal Payment Cancelled")
//        paymentViewController.dismiss(animated: true, completion: nil)
//        commonPaymentHandlerDelegate.paymentFailed(errorMsg: "PayPal Payment Cancelled")
//        return
//    }
//
//    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
//        paymentViewController.dismiss(animated: true, completion: nil)
//        print(completedPayment)
//        print("\nConfirmation \((completedPayment.confirmation["response"] as! NSDictionary))")
//        print("Transaction Id = \(((completedPayment.confirmation["response"] as! NSDictionary)["id"] as! String))")
//        self.transactionId = ((completedPayment.confirmation["response"] as! Dictionary<String, Any>)["id"] as! String)
//        self.paymentDone()
//    }
//
//
//}


extension CommonPaymentHandler : STPPaymentContextDelegate
{
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        
        SVProgressHUD.show()
        
        apiOBJ.completeCharge(paymentResult, amount: paymentContext.paymentAmount, currency: paymentBasicRequirement.currency, shippingAddress: nil, shippingMethod: nil, completion: { (error) in
             SVProgressHUD.dismiss()
            if let error = error {
                completion(STPPaymentStatus.error,error)
            } else {
                completion(STPPaymentStatus.error,nil)
            }
        }) { (response) in
            print(response)
              SVProgressHUD.dismiss()
            if response["status_code"] as! NSNumber == 1
            {
            if let transactionId = (response["data"] as! NSDictionary)["id"] as? String
            {
              self.transactionId = transactionId
                
            }
            }
            else
            {
                self.commonPaymentHandlerDelegate.paymentFailed(errorMsg: (response["message"] as! String))
            }
            
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        
        commonPaymentHandlerDelegate.paymentFailed(errorMsg: error.localizedDescription)
        
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
    }
    
//    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
//
//        SVProgressHUD.show()
//
//        apiOBJ.completeCharge(paymentResult, amount: paymentContext.paymentAmount, currency: paymentBasicRequirement.currency, shippingAddress: nil, shippingMethod: nil, completion: { (error) in
//             SVProgressHUD.dismiss()
//            if let error = error {
//                completion(error)
//            } else {
//                completion(nil)
//            }
//        }) { (response) in
//            print(response)
//              SVProgressHUD.dismiss()
//            if response["status_code"] as! NSNumber == 1
//            {
//            if let transactionId = (response["data"] as! NSDictionary)["id"] as? String
//            {
//              self.transactionId = transactionId
//
//            }
//            }
//            else
//            {
//                self.commonPaymentHandlerDelegate.paymentFailed(errorMsg: (response["message"] as! String))
//            }
//
//        }
//    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        switch status {
        case .error:
            print(error!)
        case .success:
            // if  paymentContext.selectedPaymentMethod == paymentContext.sele
            paymentDone()
        case .userCancellation:
            return // Do nothing
        }
    }
    
}

//extension CommonPaymentHandler : PGTransactionDelegate {
//        private func setupPaytm(MID:String,ORDER_ID:String,CUST_ID:String,CHANNEL_ID:String,INDUSTRY_TYPE_ID:String,WEBSITE:String,TXN_AMOUNT:String,CHECKSUMHASH:String,CALLBACK_URL:String,EMAIL:String,MOBILE_NO:String) {
//               var txnController  =  PGTransactionViewController()
//                   serverEnv = PGServerEnvironment()
//                   serverEnv = serverEnv.createStagingEnvironment()
//              print(serverEnv.serverEnvironmentCreated())
//                  let type :ServerType!
//               // Live
//               if WEBSITE == "DEFAULT" {
//                 type = .eServerTypeProduction
//               }
//               // Staging
//               else {
//                   type = .eServerTypeStaging
//               }
//                 let order = PGOrder(orderID: ORDER_ID, customerID: CUST_ID, amount: TXN_AMOUNT, eMail: EMAIL, mobile:  MOBILE_NO)
//              order.params = ["MID":MID,
//                      "ORDER_ID":ORDER_ID,
//                      "CUST_ID":CUST_ID,
//                      "CHANNEL_ID":CHANNEL_ID,
//                      "INDUSTRY_TYPE_ID":INDUSTRY_TYPE_ID,
//                      "WEBSITE": WEBSITE,
//                      "TXN_AMOUNT": TXN_AMOUNT,
//               "CHECKSUMHASH":CHECKSUMHASH,
//               "CALLBACK_URL" :CALLBACK_URL,"EMAIL":EMAIL,"MOBILE_NO":MOBILE_NO]
//
//       //        order.params = order_dict
//       //  self.txnController =  (self.txnController.initTransaction(for: order) as! PGTransactionViewController)
//               print(order)
//               txnController = (txnController.initTransaction(for: order) as! PGTransactionViewController)
//               txnController.title = "Paytm Payments"
//               txnController.setLoggingEnabled(true)
//                  if(type != ServerType.eServerTypeNone) {
//                    txnController.serverType = type;
//                  } else {
//                   print("cdsd")
//                      return
//                  }
//               txnController.merchant = PGMerchantConfiguration.defaultConfiguration()
//               txnController.delegate = self
//               paytmBasicRequirement.currentlyVC.navigationController!.isNavigationBarHidden = false
//               paytmBasicRequirement.currentlyVC.navigationController!.pushViewController(txnController
//                      , animated: true)
//              }
//
//          //this function triggers when transaction gets finished
//           func didFinishedResponse(_ controller: PGTransactionViewController, response responseString: String) {
//               let msg : String = responseString
//               var titlemsg : String = ""
//               if let data = responseString.data(using: String.Encoding.utf8) {
//                   do {
//                       if let jsonresponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] , jsonresponse.count > 0{
//                           titlemsg = jsonresponse["STATUS"] as? String ?? ""
//                           print(jsonresponse)
//                           if titlemsg == "TXN_SUCCESS" {
//                                self.PaytmPaymentDone(data: jsonresponse as AnyObject)
//                           }
//                           else {
//                               controller.navigationController?.popViewController(animated: true)
//                           }
//                           return
//                       }
//                   } catch {
//                       print("Something went wrong")
//                   }
//               }
//               let actionSheetController: UIAlertController = UIAlertController(title: titlemsg , message: msg, preferredStyle: .alert)
//               let cancelAction : UIAlertAction = UIAlertAction(title: "OK", style: .cancel) {
//                   action -> Void in
//                   controller.navigationController?.popViewController(animated: true)
//               }
//               actionSheetController.addAction(cancelAction)
//              paytmBasicRequirement.currentlyVC.present(actionSheetController, animated: true, completion: nil)
//           }
//
//           //this function triggers when transaction gets cancelled
//           func didCancelTrasaction(_ controller : PGTransactionViewController) {
//               controller.navigationController?.popViewController(animated: true)
//           }
//
//           //Called when a required parameter is missing.
//           func errorMisssingParameter(_ controller : PGTransactionViewController, error : NSError?) {
//               controller.navigationController?.popViewController(animated: true)
//           }
//
//       func PaytmPaymentDone(data:AnyObject) {
//           print(data)
//           let call_api = APINAME.init().PAYTM_SUMHASH_MATCHING_API
//           WebService.requestPostUrlWithJSONDictionaryParameters(strURL: call_api, is_loader_required: true, params: data as! [String:Any], success: { (response) in
//               print(response)
//               if response["status_code"] as! NSNumber == 1 {
////                   self.placeOrderAPI(transaction_id: COMMON_FUNCTIONS.checkForNull(string: data["BANKTXNID"] as AnyObject).1)
//                self.patymProtocolDelegate.patymPaymentDone(transactionId: COMMON_FUNCTIONS.checkForNull(string: data["BANKTXNID"] as AnyObject).1)
//               }
//
//           }) { (error) in
//               print(error)
//           }
//       }
//
//}
