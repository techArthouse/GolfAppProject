//
//  FullGameDataView.swift
//  ScoreCards
//
//  Created by Arturo Aguilar on 6/23/23.
//

import SwiftUI

struct FullGameDataView: View {
    
    @State private var fullGameData: [FullGameData] = []

        let headerLabels: [String] = ["Game Id", "Tournament Flag", "Buy In", "Num Rounds", "Player Id", "Player Name", "Round Num", "Course Id", "Course Name", "Course Rating", "Slope Rating", "Par", "Total Score", "Handicap"]

        var body: some View {
            NavigationView {
//                ScrollView {
                    VStack(alignment: .leading) {
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(headerLabels, id: \.self) { label in
                                    Text(label)
                                        .frame(width: 100, alignment: .leading)  // increase the frame width as needed
                                        .rotationEffect(.degrees(-65))
                                        .fixedSize()
                                        .padding(.vertical, 28)
                                }
                            }
                            VStack(alignment: .leading) {
                                ForEach(fullGameData, id: \.self) { data in
                                    HStack(alignment: .center) {
                                        HStack {
                                            Text("\(data.gameId)")
                                                .frame(width: 100, alignment: .leading)
                                            Text("\(data.tournamentFlag.map { $0 ? "true" : "false" } ?? "N/A")")
                                                .frame(width: 100, alignment: .leading)
                                            Text("\(data.buyIn ?? 0.0)")
                                                .frame(width: 100, alignment: .leading)
                                            Text("\(data.numRounds)")
                                                .frame(width: 100, alignment: .leading)
                                            Text("\(data.playerId)")
                                                .frame(width: 100, alignment: .leading)
                                            Text("\(data.playerName)")
                                                .frame(width: 100, alignment: .leading)
                                            Text("\(data.roundNum ?? 0)")
                                                .frame(width: 100, alignment: .leading)
                                        }
                                        HStack {
                                            Text("\(data.courseId)")
                                                .frame(width: 100, alignment: .leading)
                                            Text("\(data.courseName)")
                                                .frame(width: 100, alignment: .leading)
                                            Text("\(data.courseRating)")
                                                .frame(width: 100, alignment: .leading)
                                            Text("\(data.slopeRating)")
                                                .frame(width: 100, alignment: .leading)
                                            Text("\(data.par)")
                                                .frame(width: 100, alignment: .leading)
                                            Text("\(data.totalScore)")
                                                .frame(width: 100, alignment: .leading)
                                            Text("\(data.handicap ?? 0)")
                                                .frame(width: 100, alignment: .leading)
                                        }
                                    }
                                }
                            }
                        }

                    }
//                    .padding()
//                }
                .navigationTitle("Full Game Data")
            }
            .onAppear(perform: loadFullGameData)
        }
    
    private func loadFullGameData() {
        let apiService = GolfAPIService()
        apiService.fetchFullGameData { result in
            print(result)
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.fullGameData = data
                }
            case .failure(let error):
                // In a real app, you might want to show an alert or some other error feedback to the user.
                print("Error fetching full game data: \(error)")
            }
        }
    }
}

struct FullGameDataView_Previews: PreviewProvider {
    static var previews: some View {
        FullGameDataView()
    }
}

extension FullGameData: Hashable {
    static func == (lhs: FullGameData, rhs: FullGameData) -> Bool {
        return lhs.playerId == rhs.playerId &&
        lhs.gameId == rhs.gameId && lhs.roundNum == rhs.roundNum // Add other properties here
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(playerId)
        hasher.combine(gameId) // Add other properties here
        hasher.combine(roundNum)
    }
}
