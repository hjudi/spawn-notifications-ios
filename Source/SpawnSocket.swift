//
//  SpawnSocket.swift
//  spawn-notifications-ios
//
//  Created by Hazim Judi on 2018-01-29.
//  Copyright © 2018 Butlered Bits. All rights reserved.
//

import Foundation

let BaseSocketURLStaging = "ws://localhost:6543/"
let BaseSocketURLProduction = "ws://52.70.102.69:6543/"
var BaseSocketURL : String { return Spawn.isProduction ? BaseSocketURLProduction : BaseSocketURLStaging }

let delimiter = "--//--"

let SocketHeadAuthenticate = "respawn"

let socket = Socket()

class Socket : WebSocket {
	
	fileprivate static var hasShownOfflineMessage = false
	fileprivate static var shouldAcceptFreshAuth = true
	
	struct SocketEvent {
		
		var originalHead = ""
		var head = ""
		var once = false
		var callback : ((_ data: AnyObject?, _ ack: Any?)->())?
	}
	
	var events : [SocketEvent] = []
	
	func once(message: String, event: @escaping (_ data: AnyObject?, _ ack: Any?)->()) {
		
		self.events.append(SocketEvent(originalHead: message, head: message, once: true, callback: event))
	}
	
	func on(message: String, event: @escaping (_ data: AnyObject?, _ ack: Any?)->()) {
		
		self.events.append(SocketEvent(originalHead: message, head: message, once: false, callback: event))
	}
	
	func send(withHead head: String, andData data: Any? = nil, timeout: TimeInterval = 5, timeoutBlock: Optional<()->()> = nil, andCallback callback: Optional<(_ data: AnyObject?, _ ack: Any?)->Void> = nil) {
		
		guard self.readyState == .open else { timeoutBlock?(); return }
		var r : String?
		
		if callback != nil {
			r = randomString(withLength: 10)
			
			socket.events.append(SocketEvent(originalHead: head, head: r!, once: true, callback: callback))
			
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+timeout, execute: {
				
				let eventsCopy = Array(socket.events)
				var x = 0
				while x < eventsCopy.count {
					
					if eventsCopy[safe: x]?.head == r {
						
						timeoutBlock?()
						break
					}
					x += 1
				}
			})
		}
		
		super.send(text: package(head: head, withData: data, andCallbackID: r))
	}
	
	fileprivate func package(head: String, withData data: Any? = nil, andCallbackID callbackID: String? = nil) -> String {
		
		var s = head+delimiter
		
		if data != nil {
			
			if let d = try? JSONSerialization.data(withJSONObject: data!, options: .prettyPrinted) {
				
				s.append(String(data: d, encoding: .utf8)!)
			}
		}
		
		s += delimiter
		
		if callbackID != nil {
			
			s.append(callbackID!)
		}
		
		return s
	}
	
	func routeMessage(toEvent head: String, withBody body: AnyObject?) {
		
		var x = 0
		
		for e in socket.events {
			
			if head == e.head {
				
				e.callback?(body, nil)
				
				if e.once {
					
					socket.events.remove(at: x)
					x -= 1
				}
			}
			
			x+=1
		}
	}
	
	//
	
	internal static var isUpdating = false
	
	static var authenticated = false
	
	class func authenticateAndConnect(_ completion: @escaping (_ error: String?) -> ()) {
		
		socket.events = socket.events.filter({ e in e.originalHead != "authenticationFailed" && e.originalHead != "connected" && e.originalHead != SocketHeadAuthenticate })
		
		socket.once(message: "authenticationFailed") { (data, ack) -> Void in
			print("⛔️ Authentication failed.")
			
			completion("AuthFailed")
		}
		
		socket.once(message: "connected") { data, ack in
			
			authenticate(completion)
		}
		
		socket.open(BaseSocketURL)
	}
	
	class func authenticate(_ completion:  @escaping (_ error: String?) -> ()) {
		
		guard let creds = Spawn.getCredentials() else {
			fatalError("No suitable credentials to connect to Spawn with.")
		}
		
		socket.send(withHead: SocketHeadAuthenticate, andData: ["credentials": creds], timeout: 5, timeoutBlock: {
			
			print("🔴🔴🔴 Timeout on user/authenticate!")
			
		}) { data, a in
			
			if data?.value(forKey: "success") as? Bool == true {
				
				print("\n🔑 Authenticated to spawn with appid \(Spawn.appid)\n")
				
				DispatchQueue.main.async(execute: {
					
					completion(nil)
				})
			}
			else {
				
				shouldAcceptFreshAuth = true
				print("\n⁉️🕓 Timeout during auth\n")
				completion("Timeout")
			}
		}
	}
	
	var okayToReconnect = true
	
	func reconnect() {
		
		if Socket.authenticated || okayToReconnect == false { return }
		
		if self.readyState != .open {
			
			okayToReconnect = false
			self.wakeUp()
		}
		
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
			
			self.okayToReconnect = true
			self.reconnect()
		})
	}
	
	func wakeUp(completion: Optional<()->()> = nil) {
		
		Socket.authenticateAndConnect { (error) -> () in
			
			if error == nil {
				
				Spawn.sendHeader()
				Spawn.uploadEvents()
			}
			else if error == "Timeout" {
				
			}
			else if error == "NoAuth" || error == "AuthFailed" {
				
				
				if error == "NoAuth" {
					
				}
			}
			completion?()
		}
	}
	
	@objc func appWillEnter() {
		
		self.wakeUp()
	}
	
	@objc func appWillResign() {
		
		//self.close()
	}
	
	func setup() {
		
		self.event.open = {
			
			print("\n✅🍦 Connected to server (\(BaseSocketURL)). Rock n roll! 😎\n")
			
			self.routeMessage(toEvent: "connected", withBody: nil)
			
			//statusBar.update(withStatus: .Online)
		}
		
		socket.event.error = { e in
			
			print("\n‼️ Socket error! \(e)\n")
			
			if e.localizedDescription.lowercased().range(of: "timed out") != nil {
				
				Socket.authenticated = false
				socket.close()
				
				//statusBar.update(withStatus: .Offline)
				self.reconnect()
			}
		}
		
		socket.event.close = { code, reason, wasClean in
			
			print("‼️ Socket closed, ", reason)
			Socket.authenticated = false
			
			let abnormalClosure = reason.range(of: "Normal Closure") == nil
			
			//statusBar.update(withStatus: abnormalClosure ? .OfflineAbnormal : .Offline)
			
			if abnormalClosure {
				
				self.reconnect()
			}
		}
		
		self.event.message = { message in
			
			if let m = (message as? String)?.removingPercentEncoding {
				
				if let r = m.range(of: delimiter) {
					
					let head = m.substring(to: r.lowerBound)
					let bodyStr = m.substring(from: r.upperBound)
					
					print("📡 Incoming - \(head)")
					print(bodyStr)
					
					if let d = bodyStr.data(using: String.Encoding.utf8), let o = try? JSONSerialization.jsonObject(with: d, options: .allowFragments) as AnyObject
					{
						
						socket.routeMessage(toEvent: head, withBody: o)
					}
					else if bodyStr.isEmpty == false {
						
						print("‼️ Couldn't parse incoming object: ", bodyStr)
					}
				}
				else {
					
					socket.routeMessage(toEvent: m, withBody: nil)
				}
			}
			else {
				
				print("‼️ Couldn't parse message \(message)")
			}
		}
		
		self.on(message: "authenticated") { data, ack in
			
			Socket.authenticated = true
		}
		
		self.on(message: "authenticationFailed") { (data, ack) -> Void in
			print("⛔️ Authentication failed, resetting...")
			
		}
		
		self.on(message: "disconnectedError") { (data, ack) -> Void in
			print("‼️ Connection failed, disconnected")
			
			Socket.shouldAcceptFreshAuth = true
		}
		
		
		NotificationCenter.default.addObserver(self, selector: #selector(Socket.appWillEnter), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(Socket.appWillEnter), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(Socket.appWillResign), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(Socket.appWillResign), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
	}
	
}


