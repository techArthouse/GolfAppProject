//
//  ScoreCardsApp.swift
//  ScoreCards
//
//  Created by Arturo Aguilar on 6/8/23.
//

import SwiftUI

@main
struct ScoreCardsApp: App {
    @StateObject var userAuth = UserAuthModel()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(userAuth)
        }
    }
}
