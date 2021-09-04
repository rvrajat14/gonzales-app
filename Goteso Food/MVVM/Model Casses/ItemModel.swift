//
//  ItemModel.swift
//  GotesoMM2
//
//  Created by Kishore on 07/03/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class ItemModel: NSObject, NSCoding {

    var id = ""
    var thumb_photo = ""
    var photo = ""
    var discount = ""
    var store_id = ""
    var item_description = ""
    var quantity = ""
    var price = ""
    var item_price_single = ""
    var item_price_total = ""
    var unit = ""
    var title = ""
    var active_status = ""
    var item_stock_count = ""
    var variants = NSMutableArray.init()
    var selectedVariants = NSMutableArray.init()
   
    
     init(id:String,title:String,thumb_photo:String,photo:String,discount:String,store_id:String,item_description:String,quantity:String,price:String,item_price_single:String,item_price_total:String,unit:String,active_status:String,item_stock_count:String,variants:NSMutableArray,selectedVariants:NSMutableArray) {
        
        self.id = id
        self.title = title
        self.thumb_photo = thumb_photo
        self.photo = photo
        self.discount = discount
        self.store_id = store_id
        self.item_description = item_description
        self.quantity = quantity
        self.price = price
        self.item_price_single = item_price_single
        self.item_price_total = item_price_total
        self.unit = unit
        self.active_status = active_status
        self.item_stock_count = item_stock_count
        self.variants = variants
        self.selectedVariants = selectedVariants
        
    }
    
    override init() {
        super.init()
    }
    
    
    
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as! String
        let title = aDecoder.decodeObject(forKey: "title") as! String
        let thumb_photo = aDecoder.decodeObject(forKey: "thumb_photo") as! String
        let photo = aDecoder.decodeObject(forKey: "photo") as! String
        let discount = aDecoder.decodeObject(forKey: "discount") as! String
        let store_id = aDecoder.decodeObject(forKey: "store_id") as! String
        let item_description = aDecoder.decodeObject(forKey: "item_description") as! String
        let quantity = aDecoder.decodeObject(forKey: "quantity") as! String
        let price = aDecoder.decodeObject(forKey: "price") as! String
        let item_price_single = aDecoder.decodeObject(forKey: "item_price_single") as! String
        let item_price_total = aDecoder.decodeObject(forKey: "item_price_total") as! String
        let unit = aDecoder.decodeObject(forKey: "unit") as! String
        let active_status = aDecoder.decodeObject(forKey: "active_status") as! String
        let item_stock_count = aDecoder.decodeObject(forKey: "item_stock_count") as! String
        let variants = aDecoder.decodeObject(forKey: "variants") as! NSMutableArray
        let selectedVariants = aDecoder.decodeObject(forKey: "selectedVariants") as! NSMutableArray
        
        self.init(id: id, title: title, thumb_photo: thumb_photo, photo: photo, discount: discount, store_id: store_id, item_description: item_description, quantity: quantity, price: price, item_price_single: item_price_single, item_price_total: item_price_total, unit: unit, active_status: active_status, item_stock_count: item_stock_count, variants: variants, selectedVariants: selectedVariants)
    }
    
    func encode(with aCoder: NSCoder) {
      
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(thumb_photo, forKey: "thumb_photo")
        aCoder.encode(photo, forKey: "photo")
        aCoder.encode(discount, forKey: "discount")
        aCoder.encode(store_id, forKey: "store_id")
        aCoder.encode(item_description, forKey: "item_description")
        aCoder.encode(quantity, forKey: "quantity")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(item_price_single, forKey: "item_price_single")
        aCoder.encode(item_price_total, forKey: "item_price_total")
        aCoder.encode(unit, forKey: "unit")
        aCoder.encode(active_status, forKey: "active_status")
        aCoder.encode(item_stock_count, forKey: "item_stock_count")
        aCoder.encode(variants, forKey: "variants")
        aCoder.encode(selectedVariants, forKey: "selectedVariants")
    }
    
}
