//
//  InvitePlayersView.swift
//  ScoreCards
//
//  Created by Arturo Aguilar on 6/26/23.
//

import Foundation
import SwiftUI
import Combine

struct EmailEntry: Identifiable {
    let id = UUID()
    let email: String
}

struct AnimatedRectangle {
    var id = UUID()
    var size: CGFloat = CGFloat.random(in: 50...200)
    var position: CGPoint = CGPoint(x: CGFloat.random(in: -200...400), y: CGFloat.random(in: -200...400))
    var blur: CGFloat = CGFloat.random(in: 0...20)
}

struct InvitePlayersView: View {
    @EnvironmentObject var userAuth: UserAuthModel
    @State private var email: String = ""
    @State private var showingConfirmation = false
    @State private var invitedEmails: [EmailEntry] = []
    @State private var debouncedEmailEntries: [EmailEntry] = []
    @State private var cancellables = Set<AnyCancellable>()
    @State private var animateCircles: Bool = false
    @State private var rectangles: [AnimatedRectangle] = (0..<10).map { _ in AnimatedRectangle() }


    let gameId: Int

    var body: some View {
        if gameId != 0 {
            VStack {
                Text("Invite Players")
                    .font(.title)
                    .foregroundColor(.black)
                    .padding()
                

                TextField("Enter Player Email", text: $email, prompt: Text("Email Address"))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(0)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .onSubmit {
                        guard !email.isEmpty else { return }
                        debouncedEmailEntries.insert(EmailEntry(email: email), at: 0)
                        email = ""
                        animateCircles = true // Trigger the animation
                    }
                    .border(.black, width: 1)
                    .padding(10)
                    .padding([.leading, .trailing], 12)
                
                VStack(spacing: 2) {
                    ForEach(debouncedEmailEntries, id: \.id) { entry in
                        HStack {
                            Text("\(entry.email)")
                                .font(.headline)
                                .padding([.top, .bottom, .leading], 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 5)
//                                        .stroke(Color.black, lineWidth: 2)
//                                )
                                .transition(.move(edge: .top))
                                .animation(.easeIn)
                            
                            Button(action: {
                                withAnimation {
                                    removeEmail(entry)
                                    animateCircles = true
                                }
                            }) {
                                Image(systemName: "xmark.app.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 30))
                                    .padding(7)
                                    
                            }
                        }
                    }
                }
                .padding()
                
                Button(action: {
                    invitePlayers()
                }) {
                    Text("Invite")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                }
                .padding([.leading, .trailing], 20)
                .padding(.bottom, 20)
                .alert(isPresented: $showingConfirmation) {
                    Alert(
                        title: Text("Invitation Sent"),
                        message: Text("Player invitation sent successfully!"),
                        dismissButton: .default(Text("OK"))
                    )
                }

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(invitedEmails) { entry in
                            HStack {
                                Text("\(entry.email)")
                                    .font(.headline)
                                    .padding([.top, .bottom, .leading, .trailing], 10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .transition(.move(edge: .top))
//                                    .animation(.easeIn)

                                Text("Pending")
                                    .foregroundColor(.red)
                                    .font(.system(size: 15))
                                    .padding(5)
                                    .padding([.leading, .trailing], 20)
                            }
                        }
                    }
                    .padding(10)
                }
                ZStack{
                    ForEach(rectangles, id: \.id) { rectangle in
                        Rectangle()
                            .fill(Color.blue.opacity(0.35))
                            .frame(width: rectangle.size, height: rectangle.size)
                            .position(x: rectangle.position.x, y: rectangle.position.y)
                            .blur(radius: rectangle.blur)
                            .animation(animateCircles ? .easeIn : .none, value: animateCircles)
                    }
                    .onChange(of: animateCircles) { newValue in
                        if newValue {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                animateCircles = false // Reset the animation after it has played
                                
                            }
                            rectangles = (0..<10).map { _ in AnimatedRectangle() } // Create a new set of rectangles with random attributes
                        }
                    }
                }
            }
                
            .background(
                Group  {
                    LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.16), Color.green.opacity(0.1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .edgesIgnoringSafeArea(.all)
                    
                    
                }
                
            )
            
        }
        else {
            EmptyView()
        }
        
    }
    
    private func randomCircleSize() -> CGFloat {
        CGFloat.random(in: 50...200)
    }

    private func randomCirclePosition() -> CGFloat {
        CGFloat.random(in: -200...400)
    }

    private func randomCircleBlur() -> CGFloat {
        CGFloat.random(in: 0...20)
    }
    
    private func removeEmail(_ emailEntry: EmailEntry) {
        if let index = debouncedEmailEntries.firstIndex(where: { $0.id == emailEntry.id }) {
            debouncedEmailEntries.remove(at: index)
        }
    }

    private func invitePlayers() {
        GolfAPIService.shared.invitePlayersByEmail(gameId: gameId, emailEntries: debouncedEmailEntries) { result in
            switch result {
            case .success(let confirmations):
                print("Players successfully added to game: \(confirmations)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ) {
                    invitedEmails += debouncedEmailEntries
                    debouncedEmailEntries.removeAll()
                    showingConfirmation = true
                }
            case .failure(let error):
                // Handle the error, e.g., show an error message to the user
                print("Error inviting players: \(error)")
            }
        }
    }

}





//class DummyPlayersModel: ObservableObject {
//    @Published var dummyPlayers: [Playerd] = [
//        Playerd(id: 1, name: "Player 1"),
//        Playerd(id: 2, name: "Player 2"),
//        Playerd(id: 3, name: "Player 3")
//    ]
//}

struct InvitePlayersView_Previews: PreviewProvider {
    static var previews: some View {
//        let dummyModel = PlayerdListModel()
//        dummyModel.players = [Playerd(id: 1, name: "Player 1"), Playerd(id: 2, name: "Player 2")]
        
        return InvitePlayersView(gameId: 123456)
//            .environmentObject(dummyModel)
            .previewLayout(.sizeThatFits)
    }
}




