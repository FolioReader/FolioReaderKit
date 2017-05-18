//
//  FolioReaderUserDefaults.swift
//  Pods
//
//  Created by Kevin Delord on 01/04/17.
//
//

import Foundation

class FolioReaderUserDefaults {

    /// User Defaults which are dependend on an identifier. If no identifier is given the default standard user defaults are used.
    fileprivate var userDefaults = [String: Any]()

    fileprivate var identifier: String?

    fileprivate var useStandardUserDefaultsDirectly: Bool {
        return (self.identifier == nil)
    }

    init(withIdentifier identifier: String?) {
        if let _identifier = identifier {
            self.identifier = "folioreader.userdefaults.identifier.\(_identifier)"
        }

        guard
            let prefixedIdentifier = self.identifier,
            let defaults = UserDefaults.standard.value(forKey: prefixedIdentifier) as? [String: Any] else {
                return
        }

        self.userDefaults = defaults
    }

    public func synchronize() {
        if let identifier = self.identifier {
            // Add the keys to to the user defaults it they are identifier dependend
            UserDefaults.standard.set(self.userDefaults, forKey: identifier)
        }

        UserDefaults.standard.synchronize()
    }
}

// MARK: - Getter

extension FolioReaderUserDefaults {

    internal func bool(forKey key: String) -> Bool {
        guard (self.useStandardUserDefaultsDirectly == false) else {
                return ((UserDefaults.standard.object(forKey: key) as? Bool) ?? false)
        }

        guard let value = self.userDefaults[key] as? Bool else {
            return false
        }

        return value
    }

    internal func integer(forKey key: String) -> Int {
        guard (self.useStandardUserDefaultsDirectly == false) else {
            return ((UserDefaults.standard.object(forKey: key) as? Int) ?? 0)
        }

        guard let value = self.userDefaults[key] as? Int else {
            return 0
        }

        return value
    }

    internal func value(forKey key: String) -> Any? {
        guard (self.useStandardUserDefaultsDirectly == false) else {
            return UserDefaults.standard.object(forKey: key)
        }

        return self.userDefaults[key]
    }
}
// MARK: - Setter

extension FolioReaderUserDefaults {
    
    internal func register(defaults: [String: Any]) {
        guard (self.useStandardUserDefaultsDirectly == false) else {
            UserDefaults.standard.register(defaults: defaults)
            return
        }

        for (key, value) in defaults where (self.userDefaults[key] == nil) {
            self.userDefaults[key] = value
        }

        self.synchronize()
    }

    internal func set(_ value: Any?, forKey key: String) {
        if (self.useStandardUserDefaultsDirectly == true) {
            UserDefaults.standard.set(value, forKey: key)
        } else {
            self.userDefaults[key] = value
        }

        self.synchronize()
    }
}
