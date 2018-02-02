//
//  TempEvent.swift
//  Alamofire
//
//  Created by Hazim Judi on 2018-02-01.
//

import UIKit
import RealmSwift

class TempEvent : Object {
	
	@objc dynamic var id = randomString(withLength: 10)
	@objc dynamic var slug = ""
	@objc dynamic var body = ""
	@objc dynamic var happenedAt = Date()
}
