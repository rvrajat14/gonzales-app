//
//  OnBoardingVC.swift
//  GotesoMM2
//
//  Created by Kishore on 01/03/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit
import OneSignal
import CoreLocation

class OnBoardingVC: UIViewController {

    var dataArray : NSArray!
    var currentIndex = 0
    var window : UIWindow!
    var collectionVCellSize : CGSize!
    var statusBarColor : UIColor!
    let locationManager = CLLocationManager()
    @IBOutlet weak var backVHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var pageController: UIPageControl!
    
    @IBAction func pageController(_ sender: UIPageControl) {
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        if dataArray.count > 0 {
            
            let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
            currentIndex = (visibleIndexPath?.row)!
             pageController.currentPage = currentIndex
            if visibleIndexPath?.row == dataArray.count - 1 {
                let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
                self.window = UIWindow(frame: UIScreen.main.bounds)
                let yourVc = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as? UINavigationController
                if let window = window {
                    window.rootViewController = yourVc
                }
                UIApplication.shared.statusBarView?.backgroundColor = statusBarColor
                self.window?.makeKeyAndVisible()
                print("Last")
                return
            }
            
            let nextIndexPath = IndexPath(row: (visibleIndexPath?.row)! + 1, section: (visibleIndexPath?.section)!)
            self.collectionView.scrollToItem(at: nextIndexPath, at: .right, animated: true)
            
        }
    }
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBAction func backButton(_ sender: UIButton) {
        if dataArray.count > 0 {
            
            let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
             currentIndex = (visibleIndexPath?.row)!
            pageController.currentPage = currentIndex
            if visibleIndexPath?.row == 0 {
                return
            }
            let nextIndexPath = NSIndexPath(item: (visibleIndexPath?.row)! - 1, section: (visibleIndexPath?.section)!)
            
            self.collectionView.scrollToItem(at: nextIndexPath as IndexPath, at: .left, animated: true)
        }
    }
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        nextButton.setTitle("z_next".getLocalizedValue(), for: .normal)
        
         let dict1 = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "delivery_boy")),("label1Text","y_onboarding_delivery_title".getLocalizedValue()),("label2Text","y_onboarding_delivery_desc".getLocalizedValue()),("buttonType",""),("color","white"))
        let dict2 = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "locationOnBoardingImg")),("label1Text","y_onboarding_location_title".getLocalizedValue()),("label2Text","y_onboarding_location_desc".getLocalizedValue()),("buttonType","location"),("color","orange"))
        let dict3 = NSDictionary(dictionaryLiteral: ("image",#imageLiteral(resourceName: "notificationOnBoardingImg")),("label1Text","y_onboarding_push_title".getLocalizedValue()),("label2Text","y_onboarding_push_desc".getLocalizedValue()),("buttonType","notification"),("color","blue"))
         dataArray = NSArray(arrayLiteral: dict1,dict2,dict3)
        collectionView.register(UINib(nibName: "OnBoardingCollectionCell", bundle: nil), forCellWithReuseIdentifier: "OnBoardingCollectionCell")
        UserDefaults.standard.setValue("open", forKey: "firstTimeAppOpen")
        collectionVCellSize = CGSize(width: self.view.frame.size.width, height: collectionView.frame.size.height)
        pageController.numberOfPages = dataArray.count
        statusBarColor = UIApplication.shared.statusBarView?.backgroundColor
        UIApplication.shared.statusBarView?.backgroundColor = topView.backgroundColor
    }
 
    override func viewDidAppear(_ animated: Bool) {
        collectionVCellSize = CGSize(width: self.view.frame.size.width, height: collectionView.frame.size.height)
    }
    override func viewDidDisappear(_ animated: Bool) {
       
    }
    
    //MARK: Selector
    @objc func buttonAction(_ sender : UIButton)  {
        let dataDic = (dataArray[sender.tag] as! NSDictionary)
        if (dataDic["buttonType"] as! String) == "notification" {
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                print("User accepted notifications: \(accepted)")
                let status:OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                let userID = status.subscriptionStatus.userId
                print("userID = \(String(describing: userID))")
                
            })
        }
        else if (dataDic["buttonType"] as! String) == "location" {
            
             locationManager.requestWhenInUseAuthorization()
        }
    }
    
}


extension OnBoardingVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnBoardingCollectionCell", for: indexPath) as! OnBoardingCollectionCell
        let dataDic = (dataArray[indexPath.row] as! NSDictionary)
        if (dataDic["buttonType"] as! String).isEmpty {
            cell.button.isHidden = true
            cell.buttonBackV.isHidden = true
        }
        else
        {
            cell.button.isHidden = false
            cell.buttonBackV.isHidden = false
            SHADOW_EFFECT.makeBottomShadow(forView: cell.buttonBackV, shadowHeight: 1, color: cell.button.backgroundColor!, top_shadow: false)
        }
        cell.lable1.text = (dataDic["label1Text"] as! String)
        cell.label2.text = (dataDic["label2Text"] as! String)
        cell.imgV.image = (dataDic["image"] as! UIImage)
        print("CurrentIndex =\(indexPath.row)")
       cell.imgBackViewHeightContraints.constant = self.view.frame.size.height/2.93
        self.backVHeightConstraints.constant = cell.imgBackViewHeightContraints.constant
        cell.button.tag = indexPath.row
        cell.button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
      
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == dataArray.count - 1{
            self.nextButton.setTitle("z_done".getLocalizedValue(), for: .normal)
        }
        else
        {
            self.nextButton.setTitle("z_next".getLocalizedValue(), for: .normal)
        }
        
        if indexPath.row == 0 {
            self.backButton.isHidden = true
        }
        else
        {
            self.backButton.isHidden = false
        }
        
        currentIndex = indexPath.row
        pageController.currentPage = currentIndex
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return collectionVCellSize
        return CGSize(width: self.view.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0   )
    }
    
}

