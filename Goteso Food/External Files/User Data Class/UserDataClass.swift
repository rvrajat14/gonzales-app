//
//  UserDataClass.swift
//  Laundrit
//
//  Created by Kishore on 27/09/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class UserDataClass: NSObject, NSCoding{
    
    var user_id:String!
    var user_first_name:String!
    var user_last_name:String!
    var user_email_id:String!
    var user_mobile_number:String!
    var user_session_id:String!
    var user_photo:String!
    var user_referral_code : String!
    
    
    
    init(user_id: String, user_first_name: String, user_last_name: String,user_email_id: String, user_mobile_number: String,  user_photo: String,user_session_id: String,user_referral_code:String) {
        self.user_id = user_id
        self.user_first_name = user_first_name
        self.user_last_name = user_last_name
        self.user_email_id = user_email_id
        self.user_mobile_number = user_mobile_number
        self.user_session_id = user_session_id
        self.user_photo = user_photo
        self.user_referral_code = user_referral_code
        
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let user_id = aDecoder.decodeObject(forKey: "user_id") as! String
        let user_first_name = aDecoder.decodeObject(forKey: "user_first_name") as! String
        let user_last_name = aDecoder.decodeObject(forKey: "user_last_name") as! String
        let user_email_id = aDecoder.decodeObject(forKey: "user_email_id") as! String
        let user_mobile_number = aDecoder.decodeObject(forKey: "user_mobile_number") as! String
        let user_session_id = aDecoder.decodeObject(forKey: "user_session_id") as! String
        let user_photo = aDecoder.decodeObject(forKey: "user_photo") as! String
        let user_referral_code = aDecoder.decodeObject(forKey: "user_referral_code") as! String
        
        
        self.init(user_id: user_id, user_first_name: user_first_name, user_last_name: user_last_name, user_email_id: user_email_id, user_mobile_number: user_mobile_number,  user_photo: user_photo,user_session_id: user_session_id,user_referral_code:user_referral_code)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(user_id, forKey: "user_id")
        aCoder.encode(user_first_name, forKey: "user_first_name")
        aCoder.encode(user_last_name, forKey: "user_last_name")
        aCoder.encode(user_email_id, forKey: "user_email_id")
        aCoder.encode(user_mobile_number, forKey: "user_mobile_number")
        aCoder.encode(user_photo, forKey: "user_photo")
        aCoder.encode(user_session_id, forKey: "user_session_id")
        aCoder.encode(user_referral_code, forKey: "user_referral_code")
    }
    
    
    
}

