//
//  RealmConfig.swift
//  spawn-notifications-ios
//
//  Created by Hazim Judi on 2018-02-01.
//

import UIKit
import RealmSwift


class RealmConfig {
	
	static var realm : Realm!
	static let schemaVersion = UInt64(1)
	static var tempFilesDirectory : URL?
	static var neededMigrations : [(_ realm: Realm?)->()] = []
	static let migrationBlock : (_ migration: Migration, _ oldSchemaVersion: UInt64)->() = { migration, oldSchemaVersion in
		
		if (oldSchemaVersion < 1) {
			
			neededMigrations.append({ r in
				
				try! r?.write {
					
				}
			})
		}
	}
	
	class func setup() {
		
		RealmConfig.tempFilesDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first 
		let realmPath = RealmConfig.tempFilesDirectory!.appendingPathComponent("dbspawnanalytics.realm")
		
		// Realm migration
		
		Realm.Configuration.defaultConfiguration = Realm.Configuration.init(fileURL: realmPath, inMemoryIdentifier: nil, encryptionKey: nil, readOnly: false, schemaVersion: RealmConfig.schemaVersion, migrationBlock: { migration, oldSchemaVersion in
			
			RealmConfig.migrationBlock(migration, oldSchemaVersion)
			
		}, deleteRealmIfMigrationNeeded: false, objectTypes: nil)
		
		RealmConfig.realm = try! Realm()
		
		for m in RealmConfig.neededMigrations { m(RealmConfig.realm) }
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

