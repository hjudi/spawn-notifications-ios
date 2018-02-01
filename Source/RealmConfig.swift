//
//  RealmConfig.swift
//  spawn-notifications-ios
//
//  Created by Hazim Judi on 2018-02-01.
//


import UIKit
import RealmSwift

struct RealmConfig {
	
	static let schemaVersion = UInt64(1)
	static var neededMigrations : [(_ realm: Realm?)->()] = []
	static let migrationBlock : (_ migration: Migration, _ oldSchemaVersion: UInt64)->() = { migration, oldSchemaVersion in
		
	}
}

extension Realm {
	
	func writeSafely(_ block: ()->()) {
		
		if self.isInWriteTransaction {
			
			block()
		}
		else {
			
			try! self.write(block)
		}
	}
}

