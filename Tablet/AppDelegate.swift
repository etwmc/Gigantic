//
//  AppDelegate.swift
//  Tablet
//
//  Created by Wai Man Chan on 4/17/15.
//
//

import Cocoa
import WebKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var webView: WebView!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        NSAppleEventManager.sharedAppleEventManager().setEventHandler(self, andSelector: "handleAppleEvent:withReplyEvent:", forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))

    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    func handleAppleEvent(event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        if let urlString = event.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
            if let url = NSURL(string: urlString), let scheme = url.scheme {
                switch scheme {
                case "lyric":
                    if let singerName = url.host, let songTitle = url.lastPathComponent {
                        if let webLyricAddr = ("http://lyrics.wikia.com/api.php?artist="+singerName+"&song="+songTitle+"&fmt=html").stringByAddingPercentEscapesUsingEncoding(NSStringEncoding(NSUTF8StringEncoding)) {
                            webView.mainFrameURL = webLyricAddr
                        }
                    }
                    break
                    
                default:
                break
                }
                
            }
            
        }
    }
    
}

