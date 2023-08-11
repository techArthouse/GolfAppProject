//
//  GamePlayersView.swift
//  ScoreCards
//
//  Created by Arturo Aguilar on 6/28/23.
//


import SwiftUI

struct GamePlayersView: View {
    @EnvironmentObject var userAuth: UserAuthModel
    @State private var shouldStartNextRound = false
    @State private var shouldNavigateToScoreboard = false
    @State private var roundNum: Int = 1
    @State private var showingInvitePlayers = false // Added state variable for showing InvitePlayersView

    let gameID: Int
    let maxRoundNumber: Int // Set the maximum round number based on the game configuration

    private var isCurrentUserInGame: Bool {
        return gamePlayers.contains(where: { $0.playerId == userAuth.playerId })
    }
    
    private var isCurrentUserActive: Bool {
        // iif we find a round with no score then they are still in the running.
        guard let gamePlayer = gamePlayers.first(where: {$0.playerId == userAuth.playerId && $0.totalScore == nil}) else {
            return false
        }
        return true
    }
    
    private var currentUserNextActiveRound: Bool {
        // check if they have any rounds left
        // TASK: find the next round the current user has. The number round. we can do this similarly to calculateNextRoundToComplete. we can count all the rounds for the current user where total_score is not null. if there are less than the maxNumberOfRounds then just add one and return that value for round number
        return false // change his to correctly reflect logic
    }

    let headerLabels: [String] = ["Player Name", "Round Num", "Total Score", "Handicap"] // Add more labels as needed

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer() // Add spacer to center the buttons
                Button(action: { decrementRoundNum() }) {
                    Image(systemName: "minus")
                }
                Text("Round \(roundNum)")
                Button(action: { incrementRoundNum() }) {
                    Image(systemName: "plus")
                }
                Spacer() // Add spacer to center the buttons
            }
            .padding()

            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 5) { // Increase spacing between header labels
                        ForEach(headerLabels, id: \.self) { label in
                            Text(label)
                                .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                                .rotationEffect(.degrees(-65))
                                .padding(.vertical, 8)
                        }
                    }
                    .padding(.horizontal)

                    ForEach(filteredByRoundNumberGamePlayers, id: \.self) { gamePlayer in
                        HStack {
                            Text(gamePlayer.playerName)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(getPlayerNameColor(gamePlayer: gamePlayer)) // Apply text color based on condition
                            Text("\(gamePlayer.roundNum)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(getPlayerNameColor(gamePlayer: gamePlayer)) // Apply text color based on condition
                            Text(gamePlayer.totalScore == nil ? "N/A": "\(gamePlayer.totalScore!)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(getPlayerNameColor(gamePlayer: gamePlayer)) // Apply text color based on condition
                            Text("\(gamePlayer.handicap ?? "N/A")")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(getPlayerNameColor(gamePlayer: gamePlayer)) // Apply text color based on condition
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(
                            GeometryReader { geometry in
                                let completionFraction = calculateCompletionFraction(forPlayerId: gamePlayer.playerId)
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        Gradient.Stop(color: getFillColor(gamePlayer: gamePlayer), location: 0),
                                        Gradient.Stop(color: getFillColor(gamePlayer: gamePlayer), location: (completionFraction / (1.2 *  CGFloat(roundNum)))),
                                        Gradient.Stop(color: .clear, location: completionFraction )
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .mask(
                                    Rectangle() // Replace LineShape with your desired shape representing the line
                                        .strokeBorder(Color.gray.opacity(1), lineWidth: 1) // Customize the color and line width as needed
                                        .frame(height:  2, alignment: .bottom) // Adjust the height of the line
                                        .position(CGPoint(x: 200, y: 25))
                                )
                            }
                        )
                    }
                }
            }
            .padding()

            HStack(spacing: 0) {
                if userAuth.playerId == hostID { // Display invite button if current user is host and it's their current round
                    Button(action: {
                        showingInvitePlayers = true
                    }) {
                        Text("Invite Players")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }

                if isCurrentUserInGame && isCurrentUserActive {
                    Button(action: {
                        shouldStartNextRound = true
                    }) {
                        Text("Start Next Round")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }

            Spacer()
        }
        .sheet(isPresented: $showingInvitePlayers, onDismiss: {
            fetchGamePlayers() // Refresh game players data when the sheet is dismissed
        }) {
            InvitePlayersView(gameId: gameID)
        }
        .onAppear {
            fetchGamePlayers {
                calculateNextRoundToComplete() // must wait til gameplayers populates
            }
            fetchGameHost()

        }
        .alert(isPresented: $shouldStartNextRound) {
            Alert(
                title: Text("Start Next Round"),
                message: Text("Are you sure you want to start the next round?"),
                primaryButton: .default(Text("Yes")) {
                    shouldNavigateToScoreboard = true
                },
                secondaryButton: .cancel(Text("No"))
            )
        }
        .background(
            NavigationLink(
                destination: ScoreboardView(players: [
                    SPlayer(name: userAuth.givenName, scores: Array(repeating: 0, count: 9))
                ]).environmentObject(userAuth).environmentObject(FocusStatus()),
                isActive: $shouldNavigateToScoreboard,
                label: EmptyView.init
            )
        )
    }

    private func calculateNextRoundToComplete() {
        let zeroScoresCount = filteredByRoundNumberGamePlayers.filter { $0.totalScore == nil }.count
        let nextRoundToComplete = maxRoundNumber - zeroScoresCount + 1
        guard nextRoundToComplete <= maxRoundNumber else {
            return
        }
        roundNum = nextRoundToComplete
    }

    private func getPlayerNameColor(gamePlayer: GamePlayer) -> Color {
        if gamePlayer.totalScore == nil {
            return Color.gray.opacity(0.5) // Return a dim color for text
        } else if gamePlayer.playerId == userAuth.playerId {
            return Color.green // Return the primary color
        } else {
            return Color.primary
        }
    }

    private func getFillColor(gamePlayer: GamePlayer) -> Color {
        if gamePlayer.totalScore == nil {
            return Color.gray // Return a grey color
        } else {
            return Color.green // Return the green color
        }
    }

    private var filteredByRoundNumberGamePlayers: [GamePlayer] {
        gamePlayers.filter { $0.roundNum == roundNum }.sorted { $0.totalScore ?? 0 > $1.totalScore ?? 0 }
    }

    func calculateCompletionFraction(forPlayerId playerId: Int) -> Double {
        let filteredGamePlayers = gamePlayers.filter { $0.playerId == playerId }
        let zeroScoresCount = filteredGamePlayers.filter { $0.totalScore == nil }.count
        let completionFraction = 1.0 - (Double(zeroScoresCount) / Double(filteredGamePlayers.count))
        return completionFraction
    }

    @State private var gamePlayers: [GamePlayer] = []
    @State private var hostID: Int = 0

    private func fetchGamePlayers(completion: (() -> Void)? = nil) {
        guard let url = URL(string: "http://localhost:5001/gameplayers/\(gameID)") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }

            do {
                let decodedData = try JSONDecoder().decode([PlayerData].self, from: data)
                let gamePlayers = decodedData.map { playerData -> GamePlayer in
                    return GamePlayer(gameId: nil,
                                      playerId: playerData.playerId,
                                      playerName: playerData.playerName,
                                      roundId: playerData.roundId,
                                      roundNum: playerData.roundNum,
                                      totalScore: playerData.totalScore,
                                      handicap: playerData.handicap)
                }

                DispatchQueue.main.async {
                    self.gamePlayers = gamePlayers
                    completion?()
                }
            } catch {
                print("Error decoding gamePlayers data: \(error)")
            }
        }
        .resume()
    }

    private func incrementRoundNum() {
        if roundNum < maxRoundNumber {
            roundNum += 1
        }
    }

    private func decrementRoundNum() {
        if roundNum > 1 {
            roundNum -= 1
        }
    }

    private func getForegroundColor(gamePlayer: GamePlayer) -> Color {
        if gamePlayer.roundNum == roundNum && gamePlayer.playerId == userAuth.playerId {
            return .green
        } else {
            return .primary
        }
    }

    private func fetchGameHost() {
        GolfAPIService.getGameHost(gameId: gameID) { result in
            switch result {
            case .success(let hostID):
                DispatchQueue.main.async {
                    self.hostID = hostID ?? 0
                }
            case .failure(let error):
                print("Error fetching game host: \(error)")
            }
        }
    }

    func navigateToScoreboard() {
        shouldNavigateToScoreboard = true
    }
}


struct GamePlayersView_Previews: PreviewProvider {
    @EnvironmentObject var userAuth: UserAuthModel

    static var previews: some View {
        // Create an instance of UserAuthModel
        let userAuthModel = UserAuthModel()

        // Update the desired value in UserAuthModel
        userAuthModel.playerId = 1// Example change
        userAuthModel.accessToken = ""
        

        return GamePlayersView(gameID: 1, maxRoundNumber: 5)
            .environmentObject(userAuthModel)
    }
}
