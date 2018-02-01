//
//  SpawnNotifications.swift
//  spawn-notifications-ios
//
//  Created by Hazim Judi on 2018-01-29.
//  Copyright © 2018 Butlered Bits. All rights reserved.
//

import UIKit

public class Spawn {
	
	internal static var logPublic = true
	internal static var isProduction = false
	internal static var appid = ""
	internal static var appkey = ""
	
	public init() { }
	
	class public func with(appid: String, appkey: String) {
		
		Spawn.appid = appid
		Spawn.appkey = appkey
		
		Device.setup()
		socket.setup()
	}
	
	class func sendHeader() {
		
		socket.send(withHead: "analytics-header", andData: ["credentials": getCredentials() ?? [:]], timeout: 0, timeoutBlock: nil) { (data, ack) in
			
			if data?.bool(forKey: "success") == true {
				
				slog("Successfully sent Analytics-Header")
			}
		}
	}
	
	public class func log(_ slug: String, body: Any?) {
		
		var bodyString = body.debugDescription ?? ""
		
		socket.send(withHead: "event/log", andData: ["credentials": Spawn.getCredentials() ?? [:], "slug": slug, "body": bodyString], timeout: 0, timeoutBlock: nil) { (data, ack) in
			
			
		}
	}
	
	class func uploadEvents() {
		
		
	}
	
	
	
	class func getCredentials() -> [String: Any]? {
		
		return appid.isEmpty == false && appkey.isEmpty == false && Device.publicDeviceKey.isEmpty == false ? ["appId": appid, "appKey": appkey, "publicDeviceKey": Device.publicDeviceKey] : nil
	}
}
