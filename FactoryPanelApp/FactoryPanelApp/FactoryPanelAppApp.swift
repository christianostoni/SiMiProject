//
//  FactoryPanelAppApp.swift
//  FactoryPanelApp
//
//  Created by Christian Ostoni on 06/06/2026.
//

import SwiftUI

@main
struct FactoryPanelAppApp: App {
    @State private var appVM = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appVM)
        }
    }
}
