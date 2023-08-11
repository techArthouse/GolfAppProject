//
//  PlayerGamesView.swift
//  ScoreCards
//
//  Created by Arturo Aguilar on 6/28/23.
//

import SwiftUI

struct PlayerGamesView: View {
    @EnvironmentObject var userAuth: UserAuthModel
    @State private var playerGames: [PlayerGame] = []

    let headerLabels: [String] = ["Game Name", "Number of Players", "Rounds Completed", "Total Rounds", "Buy-In"] // Add more labels as needed

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) { // Increase spacing between header labels
                        ForEach(headerLabels, id: \.self) { label in
                            Text(label)
                                .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
                                .rotationEffect(.degrees(-65))
                                .padding(.vertical, 0)
                        }
                    }
                    .padding(.vertical)

                    ForEach(playerGames, id: \.self) { game in
                        NavigationLink(destination: GamePlayersView(gameID: game.gameID, maxRoundNumber: game.totalRounds)) {
                            HStack {
                                Text(game.gameName)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(game.numPlayers)")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(game.roundsCompleted)")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(game.totalRounds)")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(game.buyIn?.description ?? "N/A")")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
            }
            Spacer()
        }
        .onAppear {
            fetchPlayerGames(playerId: userAuth.playerId)
        }
    }

    private func fetchPlayerGames(playerId: Int) {
        guard let url = URL(string: "http://localhost:5001/playergames/\(playerId)") else {
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                return
            }

            do {
                let decoder = JSONDecoder()
                let playerGames = try decoder.decode([PlayerGame].self, from: data)

                DispatchQueue.main.async {
                    self.playerGames = playerGames
                }
            } catch {
                print("Error decoding player games data: \(error)")
            }
        }
        .resume()
    }
}

struct PlayerGamesView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerGamesView()
            .environmentObject(UserAuthModel()) // Add a UserAuthModel instance here if needed
    }
}


struct PlayerGame: Codable, Identifiable, Hashable {
    let id: UUID = UUID()
    let buyIn: String?
    let gameID: Int
    let gameName: String
    let numPlayers: Int
    let roundsCompleted: Int
    let totalRounds: Int
    
    enum CodingKeys: String, CodingKey {
        case buyIn = "buy_in"
        case gameID = "game_id"
        case gameName = "game_name"
        case numPlayers = "num_players"
        case roundsCompleted = "rounds_completed"
        case totalRounds = "total_rounds"
    }
}
