//
//  SpawnNotifications.swift
//  spawn-notifications-ios
//
//  Created by Hazim Judi on 2018-01-29.
//  Copyright © 2018 Butlered Bits. All rights reserved.
//

import UIKit
import RealmSwift

public class Spawn : NSObject, CrashEyeDelegate {
	
	internal static var instance : Spawn?
	internal static var logPublic = true
	internal static var isProduction = false
	internal static var appid = ""
	internal static var appkey = ""
	
	public override init() { }
	
	class public func with(appid: String, appkey: String) {
		
		instance = Spawn()
		Spawn.appid = appid
		Spawn.appkey = appkey
		
		RealmConfig.setup()
		Device.setup()
		socket.setup()
		CrashEye.add(delegate: instance!)
	}
	
	class func sendHeader() {
		
		socket.send(withHead: "analytics/header", andData: ["credentials": getCredentials() ?? [:], "deviceName": UIDevice.current.deviceType.displayName], timeout: 0, timeoutBlock: nil) { (data, ack) in
			
			if data?.value(forKey: "success") as? Bool == true {
				
				slog("Successfully sent Analytics-Header")
			}
		}
	}
	
	static let realmQueue = DispatchQueue(label: "spawnRealmQueue", qos: .default)
	
	public class func log(_ slug: String, info: Any?) {
		
		var bodyString = ""
		
		if let body = info as? String {
			bodyString = body
		}
		else if let body = info as AnyObject? {
			bodyString = body.description
		}
		
		if slug == "crash" {
			
			let dateFormatter = DateFormatter()
			//dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			
			let eventObjects = [["slug": slug, "body": bodyString, "happenedAt": dateFormatter.string(from:  Date())]] as [[String: Any]]
			
			socket.send(withHead: "analytics/log", andData: ["credentials": Spawn.getCredentials() ?? [:], "events": eventObjects], timeout: 0, timeoutBlock: nil) { (data, ack) in
				
				if data?.value(forKey: "success") as? Bool == true {
					
				}
			}
		}
		
		realmQueue.async {
			
			let r = try! Realm()
			r.writeSafely {
				
				let e = TempEvent()
				e.slug = slug
				e.body = bodyString
				r.add(e)
				
				DispatchQueue.main.async {
					
					Spawn.uploadEvents()
				}
			}
		}
	}
	
	class func uploadEvents() {
		
		guard Socket.authenticated else {
			slog("Spawn offline -- postponing uploadEvents")
			return
		}
		
		let dateFormatter = DateFormatter()
		//dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		
		let r = try! Realm()
		r.refresh()
		let events = Array(r.objects(TempEvent.self))
		let eventObjects = events.map({ return ["slug": $0.slug, "body": $0.body, "happenedAt": dateFormatter.string(from:  $0.happenedAt)] }) as [[String: Any]]
		
		socket.send(withHead: "analytics/log", andData: ["credentials": Spawn.getCredentials() ?? [:], "events": eventObjects], timeout: 0, timeoutBlock: nil) { (data, ack) in
			
			if data?.value(forKey: "success") as? Bool == true {
				
				r.writeSafely {
					
					r.delete(events)
				}
			}
		}
	}
	
	public func crashEyeDidCatchCrash(with model: CrashModel) {
		let info = "\(model.name ?? "") - \(model.reason ?? "") - \(model.callStack ?? "")"
		slog(info, forcePublic: true)
		Spawn.log("crash", info: info)
	}
	
	
	class func getCredentials() -> [String: Any]? {
		
		return appid.isEmpty == false && appkey.isEmpty == false && Device.publicDeviceKey.isEmpty == false ? ["appId": appid, "appKey": appkey, "publicDeviceKey": Device.publicDeviceKey] : nil
	}
}
