//
//  CreateGameView.swift
//  ScoreCards
//
//  Created by Arturo Aguilar on 6/24/23.
//

import SwiftUI

struct CreateGameView: View {
    @State private var gameName: String = ""
    @State private var numRounds: Int = 1
    @State private var deadline: Date = Date()
    @State private var tournamentFlag: String = ""
    @State private var buyIn: String = ""
    @State private var showAlert = false
    @State private var showAlertForBuyIn = false
    @State private var gameId: Int?
    @State private var invitedPlayers: [String] = []
    @State private var navigateToInvitePlayers = false
    @State private var datePicked: Bool = false
    @EnvironmentObject var userAuth: UserAuthModel

    let tournamentOptions = ["Yes", "No"]

    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.9607843137, green: 0.9725490196, blue: 0.9803921569, alpha: 1))
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Create New Game")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(#colorLiteral(red: 0.2745098039, green: 0.3529411765, blue: 0.4235294118, alpha: 1)))

                VStack {
                    TextField("Enter Game Name", text: $gameName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10.0)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                        .animation(.easeIn)

                    
                    if !gameName.isEmpty {
                        Stepper(value: $numRounds, in: 1...10) {
                            Text("Number of Rounds: \(numRounds)")
                                .foregroundColor(Color(#colorLiteral(red: 0.2745098039, green: 0.3529411765, blue: 0.4235294118, alpha: 1)))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10.0)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                    }

                    if numRounds != 1 {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10.0)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                            .animation(.easeIn)
                            .onChange(of: deadline, perform: { value in
                                self.datePicked = true
                            })
                    }

                    if datePicked {
                        Text("Is this game a tournament?")
                            .font(.headline)
                            .padding(.bottom, 10)
                        
                        HStack {
                            Button(action: {
                                self.tournamentFlag = "Yes"
                            }) {
                                Text("Yes")
                                    .padding()
                                    .background(tournamentFlag == "Yes" ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                self.tournamentFlag = "No"
                            }) {
                                Text("No")
                                    .padding()
                                    .background(tournamentFlag == "No" ? Color.blue : Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        .animation(.easeIn)
                    }

                    if !tournamentFlag.isEmpty {
                        TextField("Buy in amount (0 if none)", text: $buyIn)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10.0)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 15, trailing: 0))
                            .onChange(of: buyIn) { newValue in
                                guard let valueAsInt = Int(newValue), valueAsInt <= 10000 else {
                                    showAlertForBuyIn = true
                                    buyIn = ""
                                    return
                                }
                            }
                            .alert(isPresented: $showAlertForBuyIn) {
                                Alert(title: Text("Invalid Buy In Amount"), message: Text("Please enter a whole number between 0 and 10000"), dismissButton: .default(Text("OK")))
                            }
                    }

                    if !buyIn.isEmpty {
                        Button(action: {
                            if gameName.isEmpty {
                                showAlert = true
                            } else {
                                createGame()
                            }
                        }) {
                            Text("Create Game")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(15.0)
                                .animation(.easeIn)
                        }
                        .padding([.leading, .trailing], 20)
                    }
                }
                .padding()

                Spacer()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Missing Information"), message: Text("Please enter a name for the game."), dismissButton: .default(Text("OK")))
        }
        .background(
            NavigationLink(
                destination: InvitePlayersView(gameId: gameId ?? 0),
                isActive: $navigateToInvitePlayers,
                label: EmptyView.init
            )
        )
    }
    
    private func onDateSelected() {
        self.datePicked = true
    }

    private func createGame() {
        let apiService = GolfAPIService()
        let isTournament = tournamentFlag == "Yes" ? 1 : 0
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let deadlineString = formatter.string(from: deadline)
        apiService.createGame(name: gameName, numRounds: numRounds, deadline: deadlineString, tournamentFlag: (isTournament != 0), buyIn: Double(buyIn)!, playerId: userAuth.playerId) { result in
            switch result {
            case .success(let gameId):
                DispatchQueue.main.async {
                    self.gameId = gameId
                    self.invitedPlayers.removeAll()
                    self.navigateToInvitePlayers = true
                }
            case .failure(let error):
                print("Error creating game: \(error)")
            }
        }
    }
}


struct CreateGameView_Previews: PreviewProvider {
    static var previews: some View {
        CreateGameView()
    }
}
