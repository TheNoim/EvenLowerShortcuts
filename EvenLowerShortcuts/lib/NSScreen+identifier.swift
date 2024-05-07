//
//  NSScreen+identifier.swift
//  EvenLowerShortcuts
//
//  Created by Nils Bergmann on 30/01/2023.
//

import Foundation
import AppKit

private let NSScreenNumberKey = NSDeviceDescriptionKey("NSScreenNumber")

var numberMap: [UInt32: String] = [:]

extension NSScreen {    
    public var identifier: String {
        guard let number = deviceDescription[NSScreenNumberKey] as? NSNumber else {
            return ""
        }
        
        if let uuid = numberMap[number.uint32Value] {
            return uuid
        }
                
        let cfuuid = CGDisplayCreateUUIDFromDisplayID(number.uint32Value).takeRetainedValue()
        let uuid = CFUUIDCreateString(nil, cfuuid) as String
        numberMap[number.uint32Value] = uuid;
        return uuid;
    }
}
