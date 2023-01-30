//
//  EvenLowerShortcutsApp.swift
//  EvenLowerShortcuts
//
//  Created by Nils Bergmann on 30/01/2023.
//

import SwiftUI
import ShortcutRecorder

var globalSpaces = Spaces()

@main
struct EvenLowerShortcutsApp: App {
    @StateObject var spaces = globalSpaces
    
    let controller: YabaiControl;
    
    init() {
        self.controller = YabaiControl(spaceController: globalSpaces)
    }
    
    @State var initialized = false;
    
    var body: some Scene {
        MenuBarExtra {
            Button {
                Task {
                    do {
                        try await self.controller.next();
                    } catch {
                        print("error: \(error)")
                    }
                }
            } label: {
                Text("Next")
            }
            Button {
                Task {
                    do {
                        try await self.controller.back();
                    } catch {
                        print("error: \(error)")
                    }
                }
            } label: {
                Text("Back")
            }
            Button {
                exit(0)
            } label: {
                Text("Quit")
            }
        } label: {
            if spaces.windowOwnerName != nil {
                Text("Grabbed: \(spaces.windowOwnerName!)")
            } else {
                Text("ELS: \(spaces.spaceIndex)").onAppear {
                    if initialized {
                        return
                    }
                    
                    initialized = true
                    
                    let nonAxGlobalShortcut: GlobalShortcutMonitor? = GlobalShortcutMonitor.shared
                    
                    if let shortCutMonitor = nonAxGlobalShortcut {
                        shortCutMonitor.addAction(ShortcutAction(shortcut: Shortcut(keyEquivalent: "⌃→")!) { _ in
                            print("Exec Next")
                            Task {
                                do {
                                    try await self.controller.next();
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                            return false
                        }, forKeyEvent: .down);
                        shortCutMonitor.addAction(ShortcutAction(shortcut: Shortcut(keyEquivalent: "⌃←")!) { _ in
                            print("Exec Back")
                            Task {
                                do {
                                    try await self.controller.back();
                                } catch {
                                    print("Error: \(error)")
                                }
                            }
                            return false
                        }, forKeyEvent: .down);
                    }
                }
            }
        }
    }
}
