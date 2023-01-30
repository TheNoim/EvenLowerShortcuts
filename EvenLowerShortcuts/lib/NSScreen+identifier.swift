//
//  NSScreen+identifier.swift
//  EvenLowerShortcuts
//
//  Created by Nils Bergmann on 30/01/2023.
//

import Foundation
import AppKit

private let NSScreenNumberKey = NSDeviceDescriptionKey("NSScreenNumber")

extension NSScreen {
    public var identifier: String {
        guard let number = deviceDescription[NSScreenNumberKey] as? NSNumber else {
            return ""
        }

        let uuid = CGDisplayCreateUUIDFromDisplayID(number.uint32Value).takeRetainedValue()
        return CFUUIDCreateString(nil, uuid) as String
    }
}
