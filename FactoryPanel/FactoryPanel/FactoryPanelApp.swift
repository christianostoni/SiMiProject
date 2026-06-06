//
//  FactoryPanelApp.swift
//  FactoryPanel
//
//  Created by Christian Ostoni on 28/05/2026.
//

import SwiftUI

@main
struct FactoryPanelApp: App {
    @State private var appVM = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appVM)
        }
    }
}
