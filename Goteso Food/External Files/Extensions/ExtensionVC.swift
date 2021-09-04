//
//  ExtensionVC.swift
//  My MM
//
//  Created by Kishore on 17/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class ExtensionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
}

extension UIView
{
    func leftBottomCorner()  {
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner,.layerMaxXMaxYCorner]
             
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func rightBottomCorner()  {
  
        self.clipsToBounds = true
        self.layer.cornerRadius = 16
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner,.layerMinXMaxYCorner]
         
        } else {
            // Fallback on earlier versions
        }
    }
    
    func roundTop(radius:CGFloat = 5){
       
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    func roundBottom(radius:CGFloat = 5){
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
}

extension UIApplication {
    
    var statusBarView: UIView? {
      if #available(iOS 13.0, *) {
          let tag = 38482
          let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

          if let statusBar = keyWindow?.viewWithTag(tag) {
              return statusBar
          } else {
              guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
              let statusBarView = UIView(frame: statusBarFrame)
              statusBarView.tag = tag
              keyWindow?.addSubview(statusBarView)
              return statusBarView
          }
      } else if responds(to: Selector(("statusBar"))) {
          return value(forKey: "statusBar") as? UIView
      } else {
          return nil
      }
    }
    
}


extension String {
   
    func getLocalizedValue() -> String {
        let path = Bundle.main.path(forResource: currentLanguage == "en" ? "en" : "bs", ofType: "lproj")
        let bundle = Bundle(path: path!)
        
        return  NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
    
    
    //MARK: Add New Functionality To Convert First Character into Capital
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    
    
    //MARK: Add New Functionality of converting html data in string
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}


extension UILabel
{
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    public var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
        } else {
            self.drawText(in: rect)
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }
        
        var contentSize = super.intrinsicContentSize
        var textWidth: CGFloat = frame.size.width
        var insetsHeight: CGFloat = 0.0
        var insetsWidth: CGFloat = 0.0
        
        if let insets = padding {
            insetsWidth += insets.left + insets.right
            insetsHeight += insets.top + insets.bottom
            textWidth -= insetsWidth
        }
        
        let newSize = text.boundingRect(with: CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude),
                                        options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                        attributes: [NSAttributedString.Key.font: self.font], context: nil)
        
        contentSize.height = ceil(newSize.size.height) + insetsHeight
        contentSize.width = ceil(newSize.size.width) + insetsWidth
        
        return contentSize
    }

    func setBold(size:Int)  {
       let fontD = self.font.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits.traitBold)!
        
        self.font = UIFont(descriptor: fontD, size: CGFloat(size))
    }
    
    var optimalHeight : CGFloat
    {
        get
        {
            var rect: CGRect = self.frame //get frame of label
            rect.size = (self.text?.size(withAttributes: [NSAttributedStringKey.font: UIFont(name: self.font.fontName , size: self.font.pointSize)!]))! //Calculate as per label font
            return rect.height
        }
    }
    var optimalWidth : CGFloat
    {
        get
        {
            
            var rect: CGRect = self.frame //get frame of label
            rect.size = (self.text?.size(withAttributes: [NSAttributedStringKey.font: UIFont(name: self.font.fontName , size: self.font.pointSize)!]))! //Calculate as per label font
           return  rect.width // set width to Constraint outlet
            
            
        }
    }
    
    func heightForLabel() -> CGFloat {
        
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text!
        label.sizeToFit()
        
        return label.frame.height
    }
}


extension UIScrollView {
    
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            print(childStartPoint.x)
            self.scrollRectToVisible(CGRect(x:childStartPoint.x, y:childStartPoint.y,width: view.frame.size.width + 5,height: self.frame.height), animated: animated)
        }
    }
    
    // Bonus: Scroll to top
    func scrollToTop(animated: Bool) {
        let topOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(topOffset, animated: animated)
    }
    
    // Bonus: Scroll to bottom
    func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
    
}

extension UIImage {
    var noir: UIImage {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")!
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        let output = currentFilter.outputImage!
        let cgImage = context.createCGImage(output, from: output.extent)!
        let processedImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        
        return processedImage
    }
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont(name: REGULAR_FONT, size: 15)!,.foregroundColor: UIColor.black]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSMutableAttributedString(string:text, attributes: [.font: UIFont(name: REGULAR_FONT, size: 15)!])
        append(normal)
        
        return self
    }
}


extension DispatchQueue {
    
    static func background(work: @escaping () -> ()) {
        DispatchQueue.global(qos: .userInitiated).async {
            work()
        }
    }
    
   static func main(work: @escaping () -> ()) {
        DispatchQueue.main.async {
            work()
        }
    }
    
    
    
    
//    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
//        DispatchQueue.global(qos: .background).async {
//            background?()
//            if let completion = completion {
//                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
//                    completion()
//                })
//            }
//        }
//    }
//    
}

extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}


extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(viewController: selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        }
        return viewController
    }
}

extension UIImage {
    func convertedToGrayImage() -> UIImage? {
        let width = self.size.width
        let height = self.size.height
        let rect = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        guard let cgImage = cgImage else { return nil }
        
        context.draw(cgImage, in: rect)
        guard let imageRef = context.makeImage() else { return nil }
        let newImage = UIImage(cgImage: imageRef.copy()!)
        
        return newImage
    }
}

extension UIViewController
{
    //MARK: Get Color Name From Hex Code
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

