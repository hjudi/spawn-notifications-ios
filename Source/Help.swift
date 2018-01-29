//
//  Help.swift
//
//  Created by Hazim Judi on 2015-12-15.
//  Copyright © 2015 Hazim Judi. All rights reserved.
//

import UIKit


struct help {
	
    
    static let version = UIDevice.current.systemVersion
    
    static var IS_IPHONE_6 : Bool {
        if UIScreen.main.bounds.size.height == 667.0 {
            return true
        }
        else {
            return false
        }
    }
    
    static var IS_IPHONE_6P : Bool {
        if UIScreen.main.bounds.size.height == 736.0 {
            return true
        }
        else {
            return false
        }
    }
    
    static var IS_IOS9 : Bool {
        
        if version.range(of: "9.") != nil { return true }
        return false
    }
}

func bool(fromValue value: Any?) -> Bool? {
	
	if let b = value as? Bool {
		
		return b
	}
	if let b = string(fromValue: value) {
		
		if b == "true" || b == "1" { return true }
		if b == "false" || b == "0" { return false }
	}
	if let b = int(fromValue: value) {
		
		if b == 1 { return true }
		if b == 0 { return false }
	}
	return nil
}

func float(fromValue value: Any?) -> Float? {
	
	if let f = value as? Float {
		
		return f
	}
	if let i = value as? Int {
		
		return Float(i)
	}
	if let s = value as? String, let f = Float(s) {
		
		return f
	}
	return nil
}

func int(fromValue value: Any?) -> Int? {
	
	if let i = value as? Int {
		
		return i
	}
	if let s = value as? String, let i = Int(s) {
		
		return i
	}
	return nil
}

func string(fromValue value: Any?) -> String? {
	
	if let s = value as? String {
		
		return s
	}
	if let i = value as? Int {
		
		return i.description
	}
	return nil
}


func double(fromValue value: Any?) -> Double? {
	
	if let f = value as? Double {
		
		return f
	}
	if let i = value as? Int {
		
		return Double(i)
	}
	if let s = value as? String, let f = Double(s) {
		
		return f
	}
	return nil
}

func cgfloat(fromValue value: Any?) -> CGFloat? {
	
	if let f = value as? Double {
		
		return CGFloat(f)
	}
	if let i = value as? Int {
		
		return CGFloat(i)
	}
	if let s = value as? String, let f = Float(s) {
		
		return CGFloat(f)
	}
	return nil
}
import ObjectiveC

private var tagKey : UInt8 = 0

extension NSObject {
	
	var altTag: String? {
		get {
			return objc_getAssociatedObject(self, &tagKey) as? String
		}
		set {
			objc_setAssociatedObject(self, &tagKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
		}
	}
}

class TextField : UITextField {
	
    var leftPadding = CGFloat(10)
    var topPadding = CGFloat(1)
    var rightPadding = CGFloat(0)
    var bottomPadding = CGFloat(0)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        
        return CGRect(x: leftPadding, y: topPadding, width: bounds.width-(leftPadding)-(rightPadding), height: bounds.height)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        
        return CGRect(x: leftPadding, y: topPadding, width: bounds.width-(leftPadding)-(rightPadding), height: bounds.height)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        
        return CGRect(x: leftPadding, y: topPadding, width: bounds.width-(leftPadding)-(rightPadding), height: bounds.height)
    }
}

public class ClosureSelector<Parameter> {
	
	public let selector : Selector
	private let closure : () -> ()
	
	init(withClosure closure : @escaping () -> ()){
		self.selector = #selector(ClosureSelector.target)
		self.closure = closure
	}
	
	@objc func target() {
		closure()
	}
}

var handle = 0

extension UIButton {
	
	func addTarget(for controlEvents : UIControlEvents = .touchUpInside, withClosure closure: @escaping () -> ()) {
		let closureSelector = ClosureSelector<UIButton>(withClosure: closure)
		objc_setAssociatedObject(self, &handle, closureSelector, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		self.removeTarget(self, action: nil, for: controlEvents)
		self.addTarget(closureSelector, action: closureSelector.selector, for: controlEvents)
	}
	
}



class Button: UIButton {
	
	enum ButtonMode {
		case transform
		case transformAndFade
		case fade
		case fadeInverted
		case none
	}
	
	var touchedUpInsideCallback : Optional<()->()>
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		self.addTarget(for: .touchUpInside) {
			
			self.touchedUpInside()
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func touchedUpInside() {
		
		self.touchedUpInsideCallback?()
	}
	
	override func setImage(_ image: UIImage?, for state: UIControlState) {
		super.setImage(image, for: state)
		
		super.setImage(image, for: .highlighted)
	}
	
	var mode = ButtonMode.transform
	
	func revert() {
		
		if mode == .none { return }
		
		UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions().union(.allowUserInteraction), animations: {
			
			if self.mode == .fade {
				self.alpha = 0.4
			}
			if self.mode == .fadeInverted {
				self.alpha = 1
			}
			else {
				self.layer.transform = CATransform3DMakeScale(1, 1, 1)
			}
			
			}, completion: nil)
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		if mode == .none { return }
		
		UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIViewAnimationOptions().union(.allowUserInteraction), animations: {
			
			if self.mode == .fade {
				self.alpha = 1
			}
			if self.mode == .fadeInverted {
				self.alpha = 0.4
			}
			else {
				self.layer.transform = CATransform3DMakeScale(0.9, 0.9, 0.9)
			}
			
		}, completion: nil)
		
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		
		
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		
		self.revert()
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		
		self.revert()
	}
}

extension Date {
	
    func timeElapsed() -> String {
		
        let elapsed = abs(self.timeIntervalSinceNow)
		
		if elapsed > 0 && elapsed <= 60 {
			
			return "\(Int(elapsed))s"
		}
        else if elapsed > 60 && elapsed <= 3600 {
			
            let r = NSString(format: "%.f", elapsed/120)
            return "\(r)m"
        }
        else if elapsed > 3600 && elapsed <= 86400 {
            
            let r = NSString(format: "%.f", elapsed/3600)
            return "\(r)h"
        }
        else if elapsed > 86400 && elapsed <= 604800 {
            
            let r = NSString(format: "%.f", elapsed/86400)
            return "\(r)d"
        }
        else if elapsed > 604800 && elapsed <= 2419200 {
            
            let r = NSString(format: "%.f", elapsed/604800)
            return "\(r)w"
        }
        else if elapsed > 2419200 && elapsed <= 29030400 {
            
            let r = NSString(format: "%.f", elapsed/2419200)
            return "\(r)mo"
        }
        else {
            let r = NSString(format: "%.f", elapsed/29030400)
            return "\(r)y"
        }
    }
}


extension UIView {
    
    func removeAllSubviews() {
        
        for subview in self.subviews {
            
            subview.removeFromSuperview()
        }
    }
    
    var x : CGFloat {
        
        get {
            return self.frame.origin.x
        }
        set(newX) {
            self.frame.origin.x = newX
        }
    }
    var y : CGFloat {
        
        get {
            return self.frame.origin.y
        }
        set(newY) {
            self.frame.origin.y = newY
        }
    }
    var width : CGFloat {
        
        get {
            return self.frame.width
        }
        set(newW) {
            self.frame.size.width = newW
        }
    }
    var height : CGFloat {
        
        get {
            return self.frame.height
        }
        set(newH) {
            self.frame.size.height = newH
        }
    }
}

func gradientImage(_ fromColor: UIColor, toColor: UIColor, size: CGSize, horizontal: Bool = false) -> UIImage {
    
	let s = size
		
    UIGraphicsBeginImageContext(s)
	
	guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
    let locations : [CGFloat] = [ 0.0, 1 ]
    let colors = [fromColor.cgColor, toColor.cgColor]
    let colorspace : CGColorSpace = CGColorSpaceCreateDeviceRGB()
    let gradient : CGGradient = CGGradient(colorsSpace: colorspace, colors: colors as CFArray, locations: locations)!
    let startPoint : CGPoint = CGPoint(x: 0, y: 0)
	let endPoint : CGPoint = CGPoint(x: horizontal ? s.width : 0, y: horizontal ? 0 : s.height)
    context.drawLinearGradient(gradient,start: startPoint, end: endPoint, options: CGGradientDrawingOptions.init(rawValue: 0))
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return img!
}

func hexToColor(_ hex: String) -> UIColor? {
    
    if let hexIntValue = UInt(hex, radix: 16) {
        
        return UIColor(
            red: CGFloat((hexIntValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hexIntValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hexIntValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    return nil
}

func colorToHex(_ color: UIColor) -> String {
    
    let values = color.getRGB()
    
    return String(format: "%02x%02x%02x", Int(values[0]*255), Int(values[1]*255), Int(values[2]*255))
}

func paragraphStyleWithLineHeight(_ lineHeight: CGFloat?, alignment: NSTextAlignment?) -> NSParagraphStyle {
    
    let paragraphStyle = NSMutableParagraphStyle()
    
    if lineHeight != nil { paragraphStyle.lineSpacing = lineHeight! }
    if alignment != nil { paragraphStyle.alignment = alignment! }
    
    return paragraphStyle as NSParagraphStyle
}

extension Array {
    
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

extension String.Index {
	
	func successor(in string:String)->String.Index{
		return string.index(after: self)
	}
	
	func predecessor(in string:String)->String.Index{
		return string.index(before: self)
	}
	
	func advance(_ offset:Int, for string:String)->String.Index{
		return string.index(self, offsetBy: offset)
	}
}

extension String {
    
    var length: Int { return self.count }
	
	var emojiOnly: Bool {
		
		for scalar in unicodeScalars {
			switch scalar.value {
			case 0x3030, 0x00AE, 0x00A9,// Special Characters
			0x1D000...0x1F77F,          // Emoticons
			0x2100...0x27BF,            // Misc symbols and Dingbats
			0xFE00...0xFE0F,            // Variation Selectors
			0x1F900...0x1F9FF:          // Supplemental Symbols and Pictographs
				continue
			default:
				return false
			}
		}
		return true
	}
	
	var containsEmoji: Bool {
		
		var c = false
		
		for scalar in unicodeScalars {
			switch scalar.value {
			case 0x3030, 0x00AE, 0x00A9,// Special Characters
			0x1D000...0x1F77F,          // Emoticons
			0x2100...0x27BF,            // Misc symbols and Dingbats
			0xFE00...0xFE0F,            // Variation Selectors
			0x1F900...0x1F9FF:          // Supplemental Symbols and Pictographs
				c = true
			default:
				continue
			}
		}
		return c
	}
	
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
	
    func toMentionsArray() -> Array<String> {
        
        var arrayOfMentions : Array<String> = []
        
        if self.length > 0 {
            
            var tempStr = self
            
            var containsMore = true
            
			while containsMore == true && tempStr.length > 0 {
				
				if let r = tempStr.range(of: "@") {
					
                    if arrayOfMentions.count == 0 && r.upperBound == tempStr.endIndex { containsMore = false; break }
					
					var nlb = r.lowerBound
					var nub = r.upperBound
					
					nlb = index(nlb, offsetBy: 1)
                    var hitASpace = false
					
                    while hitASpace == false {
						
                        if nub == tempStr.endIndex { hitASpace = true; break }
						
                        if String(tempStr[nub]).rangeOfCharacter(from: CharacterSet(charactersIn: " .@:!$%^&*()+=?\"\'[]\n")) != nil {
							
							hitASpace = true
							break
						}
                        
                        nub = nub.advance(1, for: tempStr)
                    }
					
					let finalMentionRange = Range(uncheckedBounds: (nlb, nub))
                    
                    if tempStr.substring(with: finalMentionRange) != "" {
                        
                        arrayOfMentions.append(tempStr.substring(with: finalMentionRange))
                    }
                    tempStr = tempStr.substring(from: finalMentionRange.upperBound)
                }
                else {
                    
                    containsMore = false
                }
            }
        }
        
        return arrayOfMentions
    }
    
    
    func minifiedURL(_ suffix: String) -> String {
        
        var s = self.removingPercentEncoding!.lowercased().replacingOccurrences(of: "http://", with: "", options: [], range: nil).replacingOccurrences(of: "https://", with: "", options: [], range: nil).replacingOccurrences(of: "www.", with: "", options: [], range: nil) as NSString
		
		let r = s.range(of: "/")
        if r.location != NSNotFound {
			
            s = s.replacingCharacters(in: NSMakeRange(r.location, s.length-r.location), with: "") as NSString
        }
		s = s.appending(suffix) as NSString
		
        return s as String
    }
}

extension Date {
	
	func compareIfNotNil(_ other: Date?) -> ComparisonResult {
		
		if other == nil {
			
			return .orderedSame
		}
		
		return self.compare(other!)
	}
}

extension UIImage {
    
    func dim(_ alpha: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size), blendMode: .normal, alpha: alpha)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func fillWithColor(_ color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let c = UIGraphicsGetCurrentContext()
        self.draw(in: CGRect(origin: CGPoint.zero, size: self.size), blendMode: .normal, alpha: 1)
        c?.setBlendMode(CGBlendMode.sourceIn)
        c?.setFillColor(color.cgColor)
        c?.fill(CGRect(origin: CGPoint.zero, size: self.size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
		return image != nil ? image! : UIImage()
    }

}

extension UIColor {
    
    
    func toImage() -> UIImage {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(self.cgColor);
        context?.fill(rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    func darkerByPercentage(_ percentage: CGFloat) -> UIColor {
        
        var red = CGFloat(); var green = CGFloat(); var blue = CGFloat(); var a = CGFloat()
        self.getRed(&red, green: &green, blue: &blue, alpha: &a)
        
        return UIColor(red: red-(percentage/100), green: green-(percentage/100), blue: blue-(percentage/100), alpha: a)
    }
    
    func lighterByPercentage(_ percentage: CGFloat) -> UIColor {
        
        var red = CGFloat(); var green = CGFloat(); var blue = CGFloat(); var a = CGFloat()
        self.getRed(&red, green: &green, blue: &blue, alpha: &a)
        
        return UIColor(red: red+(percentage/100), green: green+(percentage/100), blue: blue+(percentage/100), alpha: a)
    }
    
    func getRGB() -> [CGFloat] {
        
        var red = CGFloat(); var green = CGFloat(); var blue = CGFloat(); var a = CGFloat();
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &a)
        
        return [red,green,blue]
    }
}

func randomString(withLength length: Int) -> String {
	
	let letters = "abcdefghijklmnopqrstuvwxyz0123456789" as NSString
	
	let randomString = NSMutableString(capacity: length)
	
	var x = 0
	while x < length {
		
		let length = UInt32 (letters.length)
		let rand = arc4random_uniform(length)
		randomString.appendFormat("%C", letters.character(at: Int(rand)))
		x += 1
	}
	return randomString as String
}

func benchmark(_ label: String, closure: () -> ()) {
	
	let startTime = CFAbsoluteTimeGetCurrent()
	closure()
	let duration = Int64((CFAbsoluteTimeGetCurrent() - startTime) * 1000)
	print(label,duration,"ms")
}
