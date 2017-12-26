//
//  AppDelegate.swift
//  Docka
//
//  Created by Davide Bertola on 19/11/2016.
//  Copyright © 2016 Davide Bertola. All rights reserved.
//

import Cocoa
import CoreVideo
import Silica


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {}
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        let app:NSApplication = NSApplication.shared()
        let window:NSWindow = app.windows[0]
        window.setIsVisible(false)
    }
    
    // this is a hack to detect dock icon clicks
    // (http://www.cocoabuilder.com/archive/cocoa/238362-how-to-detect-click-on-app-dock-icon-when-the-app-is-active.html)
    func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return true
    }
    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        reactivatePreviousAppAndThen {
            AppDelegate.windowsRefit()
        }
        return true
    }
    
    func reactivatePreviousAppAndThen(callback: @escaping(() -> Void)) {
        NSWorkspace.shared().frontmostApplication!.hide()
        // it takes time to hide current app and select previous one, apparently
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { (timer) in
            callback()
        }
    }
 
    class func windowsRefit() {
        let app = NSWorkspace.shared().frontmostApplication
        
        if let siApp = SIApplication(runningApplication: app) {
            let windows = siApp.visibleWindows() as! [SIWindow]
            for window in windows {
                if window.isNormalWindow() {
                    let key = siApp.title() + window.title()
                    var index = (UserDefaults.standard.value(forKey: key) as! Int?) ?? 0
                    
                    let screen = window.screen()!.frameWithoutDockOrMenu()
                    let candidates = candidatesForScreen(screen: screen)
                    let candidate = candidates[index % 3]
                    window.setFrame(candidate)
                    
                    index += 1
                    UserDefaults.standard.setValue(index, forKey: key)
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
    
    class func candidatesForScreen(screen:CGRect) -> [CGRect]  {
        let frameLarge = screen.insetBy(
            dx: screen.width * 0.02,
            dy: screen.height * 0.03
        )
        let frameMedium = screen.insetBy(
            dx: screen.width * 0.1,
            dy: screen.height * 0.1
        )
        let frameSmall = screen.insetBy(
            dx: screen.width * 0.2,
            dy: screen.height * 0.2
        )
        let candidates = [frameLarge, frameMedium, frameSmall]
        return candidates
    }
    
}

