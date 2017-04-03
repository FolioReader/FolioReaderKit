//
//  FolioReaderUserDefaults.swift
//  Pods
//
//  Created by Kevin Delord on 01/04/17.
//
//

import Foundation

class FolioReaderUserDefaults {

	fileprivate var userDefaults	: [String: Any]
	fileprivate var identifier		: String

	init(withIdentifier identifier: String) {
		self.identifier = identifier

		guard let defaults = UserDefaults.standard.value(forKey: identifier) as? [String: Any] else {
			let emptyDefaults = [String: Any]()
			UserDefaults.standard.set(emptyDefaults, forKey: identifier)
			UserDefaults.standard.synchronize()
			self.userDefaults = emptyDefaults
			return
		}

		self.userDefaults = defaults
	}

	public func synchronize() {
		guard (self.identifier != "") else {
			fatalError("invalid user default unique identifier")
			return
		}

		UserDefaults.standard.set(self.userDefaults, forKey: self.identifier)
		UserDefaults.standard.synchronize()
	}
}

// MARK: - Getter

extension FolioReaderUserDefaults {

	internal func bool(forKey key: String) -> Bool {
		guard let value = self.userDefaults[key] as? Bool else {
			return false
		}

		return value
	}

	internal func integer(forKey key: String) -> Int {
		guard let value = self.userDefaults[key] as? Int else {
			return 0
		}

		return value
	}

	internal func value(forKey key: String) -> Any? {
		return self.userDefaults[key]
	}
}

// MARK: - Setter

extension FolioReaderUserDefaults {

	internal func register(defaults: [String: Any]) {
		for (key, value) in defaults {
			self.userDefaults[key] = value
		}

		self.synchronize()
	}

	internal func set(_ value: Any?, forKey key: String) {
		self.userDefaults[key] = value
		self.synchronize()
	}
}
