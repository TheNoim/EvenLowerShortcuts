//
//  Spaces.swift
//  EvenLowerShortcuts
//
//  Created by Nils Bergmann on 30/01/2023.
//

import Foundation
import Combine
import AppKit
import CoreGraphics
import Throttler

class Spaces: ObservableObject, SpaceObserverDelegate {
    @Published var spaceIndex = 0;
    @Published var screenWithMouse: NSScreen = NSScreen.screens.first!;
    @Published var mouseLocation: NSPoint = NSEvent.mouseLocation;
    @Published var windowIndex: Int? = nil
    @Published var windowOwnerName: String? = nil
    
    var spaces: [Space] = [];
    
    private let observer = SpaceObserver()
    private var timer: Timer? = nil;
    
    init() {
        NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { _ in
            Throttler.throttle(delay: .milliseconds(150)) {
                Task {
                    await MainActor.run {
                        self.updateMouseLocation();
                    }
                }
            }
        }
                
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown]) { (event) in
//            let location = event.locationInWindow
            let windowNumber = event.windowNumber
//            let window = NSApplication.shared.windows
//                .filter { $0.windowNumber == windowNumber }
//                .first
            
            if event.modifierFlags.contains(.option) {
                let windows = self.windowList() as? NSArray? as? [[String: Any]]
                let window = windows?.first { (info) -> Bool in
                    guard let number = info["kCGWindowNumber"] as? Int else {
                        return false
                    }
                    return number == windowNumber
                }
                
                if window != nil {
                    self.windowIndex = windowNumber
                    
                    guard let windowOwnerName = window!["kCGWindowOwnerName"] as? String else {
                        self.windowOwnerName = nil
                        return
                    }
                    
                    self.windowOwnerName = windowOwnerName
                } else {
                    self.windowIndex = nil
                    self.windowOwnerName = nil
                }
            }
        }
        
        NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp]) { (event) in
            self.windowIndex = nil
            self.windowOwnerName = nil
        }
        
        self.observer.delegate = self;
        
        self.observer.updateSpaceInformation();
        
        self.updateMouseLocation()
        
//        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
//            self.observeChanges()
//        }
        
//        self.windowList();
    }
    
    
    func didUpdateSpaces(spaces: [Space]) {
        self.spaces = spaces;
        for space in spaces {
            if space.isCurrentSpace, space.displayID == screenWithMouse.identifier {
                spaceIndex = space.spaceNumber
            }
        }
    }
    
    var index = 0;
    
    func updateMouseLocation() {
        
        let mouseLocation = NSEvent.mouseLocation
        
        self.mouseLocation = mouseLocation;
        
        let screens = NSScreen.screens
        
        let calculatedScreen = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) });
        
        if (calculatedScreen != nil) {
            var updateSpaceInformation = false;
            if calculatedScreen!.identifier != self.screenWithMouse.identifier {
                updateSpaceInformation = true;
            }
            self.screenWithMouse = calculatedScreen!
            if updateSpaceInformation {
                self.observer.updateSpaceInformation()
            }
        }
    }
    
//    var previousWindow: CGWindowID? = nil
    
//    func observeChanges() {
//        let options: CGWindowListOption = [.excludeDesktopElements, .optionOnScreenOnly]
//        let windowList = CGWindowListCopyWindowInfo(options, CGWindowID(0)) as NSArray?
//
//        for window in windowList as! [[String: Any]] {
//            let windowNumber = window[kCGWindowNumber as String] as! CGWindowID
//            let windowLevel = window[kCGWindowLayer as String] as! Int
//            if windowLevel == 0 {
//                if previousWindow != windowNumber {
//                    previousWindow = windowNumber
//                    // The frontmost window has changed
//
//                    //                    print("Window changed \(windowList)")
//                }
//                break
//            }
//        }
//    }
    
    func windowList() -> CFArray? {
        let options = CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
        let windowListInfo = CGWindowListCopyWindowInfo(options, kCGNullWindowID)
        
        return windowListInfo
    }
    
//    deinit {
//        self.timer?.invalidate();
//    }
}
