//
//  Device.swift
//  Gelato
//
//  Created by Hazim Judi on 2016-10-09.
//  Copyright © 2016 Butlered Bits. All rights reserved.
//

import UIKit
import Security

private let KeyType = kSecAttrKeyTypeRSA
private let KeySize = 2048
private let PubTag = "com.butleredbits.radio.pubKey"
private let PrivTag = "com.butleredbits.radio.privKey"

let privateKeyParams: [String: AnyObject] = [
	kSecAttrIsPermanent as String: kCFBooleanTrue,
	kSecAttrApplicationTag as String: PrivTag as AnyObject
]

let publicKeyParams: [String: AnyObject] = [
	kSecAttrIsPermanent as String: kCFBooleanTrue,
	kSecAttrApplicationTag as String: PubTag as AnyObject
]

let parameters: [String: AnyObject] = [
	kSecAttrKeyType as String: KeyType,
	kSecAttrKeySizeInBits as String: KeySize as AnyObject,
	kSecPublicKeyAttrs as String: publicKeyParams as AnyObject,
	kSecPrivateKeyAttrs as String: privateKeyParams as AnyObject
]

class Device {
	
	internal static var publicDeviceKey = ""
	
	class func setup() {
		
		if let udid = KeychainWrapper.defaultKeychainWrapper.stringForKey("deviceToken") {
			
			publicDeviceKey = udid
		}
		else {
			
			let bytesCount = 32
			var udid = ""
			var randomBytes = [UInt8](repeating: 0, count: bytesCount)
			
			_ = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)
			
			udid = randomBytes.map({String(format: "%02hhx", $0)}).joined(separator: "")
			publicDeviceKey = udid
			
			_ = KeychainWrapper.defaultKeychainWrapper.setString(udid, forKey: "deviceToken")
			
		}
	}
}
