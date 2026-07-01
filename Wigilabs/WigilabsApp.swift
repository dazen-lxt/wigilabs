//
//  WigilabsApp.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import SwiftUI
import SwiftData

@main
struct WigilabsApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: VoteRecord.self)
    }
}
