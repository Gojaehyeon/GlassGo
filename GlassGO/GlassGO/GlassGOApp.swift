//
//  GlassGOApp.swift
//  GlassGO
//
//  Created by Gojaehyun on 6/30/25.
//

import SwiftUI
import Cocoa
import HotKey

@main
struct GlassGOApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {}
    }
}
