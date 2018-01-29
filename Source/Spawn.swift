//
//  SpawnNotifications.swift
//  spawn-notifications-ios
//
//  Created by Hazim Judi on 2018-01-29.
//  Copyright © 2018 Butlered Bits. All rights reserved.
//

import UIKit

public class Spawn {
	
	internal static var isProduction = false
	internal static var appid = ""
	internal static var appkey = ""
	
	class func with(appid: String, token: String) {
		
		Device.setup()
	}
	
	internal class func getCredentials() -> [String: Any]? {
		
		return appid.isEmpty == false && appkey.isEmpty == false && Device.publicDeviceKey.isEmpty == false ? ["appId": appid, "appKey": appkey, "publicDeviceKey": Device.publicDeviceKey] : nil
	}
}
