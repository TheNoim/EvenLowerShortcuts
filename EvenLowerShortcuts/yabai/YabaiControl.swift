//
//  YabaiControl.swift
//  EvenLowerShortcuts
//
//  Created by Nils Bergmann on 30/01/2023.
//

import Foundation

class YabaiControl {
    
    let spaceController: Spaces;
    
    let yabaiClient = YabaiClient()
    
    init(spaceController: Spaces) {
        self.spaceController = spaceController;
    }
 
    func next() async throws {
        let start = CFAbsoluteTimeGetCurrent()
        
        print("Start focus next");
        
        defer {
            let diff = CFAbsoluteTimeGetCurrent() - start
            print("End focus next in \(diff) seconds")
        }
        
        await self.spaceController.updateMouseLocation()
        
        let windowId = self.spaceController.windowIndex;
        
        let spacesForCurrentDisplay = self.spaceController.spaces.filter({ $0.displayID == self.spaceController.screenWithMouse.identifier })
        
        let currentIndex = self.spaceController.spaceIndex
        
        guard let currentSpaceIndexInSpaceListIndex = spacesForCurrentDisplay.firstIndex(where: { $0.spaceNumber == currentIndex }) else {
            return;
        }
                
        var targetIndex = currentSpaceIndexInSpaceListIndex + 1;
        
        if currentSpaceIndexInSpaceListIndex == spacesForCurrentDisplay.endIndex - 1 {
            targetIndex = spacesForCurrentDisplay.startIndex;
        }
        
        targetIndex = spacesForCurrentDisplay[targetIndex].spaceNumber
        
        let _ = try await self.yabaiClient.sendMessage(arguments: ["space", "--focus", "\(targetIndex)"]);
                
        if windowId != nil {
            let _ = try await self.yabaiClient.sendMessage(arguments: ["window", "\(windowId!)", "--space", "\(targetIndex)"]);
            
            try await Task.sleep(for: .milliseconds(50))
            
            let _ = try await self.yabaiClient.sendMessage(arguments: ["window", "--focus", "\(windowId!)"]);
            
            let _ = try await self.yabaiClient.sendMessage(arguments: ["window", "--focus", "\(windowId!)"]);
        }
    }
    
    func back() async throws {
        let start = CFAbsoluteTimeGetCurrent()
        
        print("Start focus back");
        
        defer {
            let diff = CFAbsoluteTimeGetCurrent() - start
            print("End focus back in \(diff) seconds")
        }
        
        await self.spaceController.updateMouseLocation();
        
        let windowId = self.spaceController.windowIndex;
        
        let spacesForCurrentDisplay = self.spaceController.spaces.filter({ $0.displayID == self.spaceController.screenWithMouse.identifier })
        
        let currentIndex = self.spaceController.spaceIndex
        
        guard let currentSpaceIndexInSpaceListIndex = spacesForCurrentDisplay.firstIndex(where: { $0.spaceNumber == currentIndex }) else {
            return;
        }
        
        var targetIndex = currentSpaceIndexInSpaceListIndex - 1;
        
        if currentSpaceIndexInSpaceListIndex == spacesForCurrentDisplay.startIndex {
            targetIndex = spacesForCurrentDisplay.endIndex - 1;
        }
        
        targetIndex = spacesForCurrentDisplay[targetIndex].spaceNumber
        
        let _ = try await self.yabaiClient.sendMessage(arguments: ["space", "--focus", "\(targetIndex)"]);
        
        if windowId != nil {
            let _ = try await self.yabaiClient.sendMessage(arguments: ["window", "\(windowId!)", "--space", "\(targetIndex)"]);
            
            try await Task.sleep(for: .milliseconds(50))
            
            let _ = try await self.yabaiClient.sendMessage(arguments: ["window", "--focus", "\(windowId!)"]);
            
            let _ = try await self.yabaiClient.sendMessage(arguments: ["window", "--focus", "\(windowId!)"]);
        }
    }
}
