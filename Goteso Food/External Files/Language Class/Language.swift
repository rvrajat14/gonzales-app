//
//  Language.swift
//  Ordefy Customer
//
//  Created by Apple on 26/06/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import Foundation

class Language {
    
    static var isRTL : Bool {
        get {
            if (NSLocale.preferredLanguages[0] as String).contains("ar") || (NSLocale.preferredLanguages[0] as String).contains("he")
            {
                return true
            }
            return false
            
        }
    }
}
