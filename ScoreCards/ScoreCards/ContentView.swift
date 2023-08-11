//
//  ContentView.swift
//  ScoreCards
//
//  Created by Arturo Aguilar on 6/8/23.
//

import SwiftUI
import CoreData
import GoogleSignIn

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext


    var body: some View {
            NavigationView {
                LoginView()
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext).environmentObject(UserAuthModel())
    }
}
