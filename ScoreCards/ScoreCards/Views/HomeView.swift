//
//  HomeView.swift
//  ScoreCards
//
//  Created by Arturo Aguilar on 6/24/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userAuth: UserAuthModel

    var body: some View {
        NavigationView {
            ZStack {
//                Color.black.edgesIgnoringSafeArea(.all)

                VStack {
                    Text("Golf App")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.bottom, 50)
                        .shadow(color: .black, radius: 2, x: -1, y:1)

                    Image("golf-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 200)
                        .padding(.bottom, 50)

                    NavigationLink(destination: CreateGameView()) {
                        Label("Create Game", systemImage: "plus.circle.fill")
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 10)

                    NavigationLink(destination: PlayerGamesView()) {
                        Label("View Current Games", systemImage: "eye.fill")
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    if userAuth.isLoggedIn {
                        Button(action: {
                            userAuth.signOut()
                        }) {
                            Text("Sign Out")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .padding()
                                .foregroundColor(.red)
    //                            .background(Color.red)
                                .cornerRadius(10)
                                .shadow(radius: 10)
                        }
                    }
                }
            }
//            .navigationTitle("Home")
//            .toolbar {
//                if !userAuth.isLoggedIn {
//                    Button(action: {
//                        userAuth.signOut()
//                    }) {
//                        Text("Sign Out")
//                            .font(.system(size: 20, weight: .bold, design: .rounded))
//                            .padding()
//                            .foregroundColor(.red)
////                            .background(Color.red)
//                            .cornerRadius(10)
//                            .shadow(radius: 10)
//                    }
//                }
//            }
        }
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(UserAuthModel())
    }
}

