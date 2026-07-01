//
//  RootView.swift
//  Wigilabs
//
//  Created by Carlos Muñoz on 30/06/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                VotingView()
            }
            .tabItem {
                Label("tab.vote", systemImage: "hand.thumbsup")
            }

            NavigationStack {
                CatListView()
            }
            .tabItem {
                Label("catlist.title", systemImage: "cat")
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: VoteRecord.self, inMemory: true)
}
