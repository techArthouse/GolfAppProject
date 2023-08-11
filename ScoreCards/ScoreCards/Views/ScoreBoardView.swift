//
//  ScoreBoardView.swift
//  ScoreCards
//
//  Created by Arturo Aguilar on 6/30/23.
//

import Foundation
import SwiftUI


struct ScoreboardView: View {
    @EnvironmentObject var focusStatus: FocusStatus
    var players: [SPlayer] = []

    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 9)

    var body: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal) {
                HStack {
                    Text("Player/Hole")
                    ForEach(1..<10) { hole in
                        Text("Hole \(hole)")
                    }
                }
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(players.indices, id: \.self) { playerIndex in
                        
//                        Section(header: Text(players[playerIndex].name)) {
                            ForEach(players[playerIndex].scores.indices, id: \.self) { scoreIndex in
                                ScoreCell(score: players[playerIndex].scores[scoreIndex]).padding()
                            }
//                        }
                    }
                }
            }
        }
//        .overlay(
//            Group {
//                if focusStatus.focusedCell != nil {
//                    Color.black.opacity(0.6)
//                        .ignoresSafeArea(.all, edges: .all)
//                    // .animation(.easeIn)
//                }
//            }
//        )
    }
}


struct ScoreCell: View {
    let id = UUID() // to identify this view
    let score: Int

    @EnvironmentObject var focusStatus: FocusStatus

    var isFocused: Bool {
        id == focusStatus.focusedCell
    }

    var body: some View {
        Button(action: {
            withAnimation {
                if self.isFocused {
                    self.focusStatus.focusedCell = nil
                } else {
                    self.focusStatus.focusedCell = id
                }
            }
        }) {
            Text("\(score)")
                .font(.system(size: isFocused ? 160 : 54, weight: .regular))
                .foregroundColor(score < 0 ? .blue : (score > 0 ? .red : .black))
                .padding()
                .frame(width: isFocused ? 280 : 80, height: isFocused ? 280 : 110)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 2)
                )
        }
        .zIndex(isFocused ? 1 : 0)
        .background(self.focusStatus.focusedCell == id ? Color.black.opacity(0.3) : Color.clear)
    }
}


struct SPlayer {
    let id = UUID() // not sure why we don't just use playerid as that's unique
    let name: String
    var scores: [Int]
    
    var totalScore: Int? {
        scores.reduce(0, +)
    }
}

struct Score: Identifiable {
    let id = UUID()
    var value: Int
}

class FocusStatus: ObservableObject {
    @Published var focusedCell: UUID? = nil
}


struct ScoreboardView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreboardView(players: [
            SPlayer(name: "Player 1", scores: Array(repeating: 0, count: 9)),
            SPlayer(name: "Player 2", scores: Array(repeating: 0, count: 9))
        ]).environmentObject(FocusStatus())
        .previewDevice("iPhone 12 Pro")
    }
}

struct PlayerRow: View {
    let player: SPlayer
    @EnvironmentObject var focusStatus: FocusStatus

    var body: some View {
        HStack(spacing: 0) {
            Text(player.name)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.black)
                .padding()
                .frame(width: 120, height:  49)
                .background(Color.white.opacity(0.5))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .shadow(color: .black, radius: 3, x: 15, y: 7)
                )

            ForEach(player.scores, id: \.self) { score in
                ScoreCell(score: score)
                    .frame(width: 80, height: 10)
            }

            TotalScoreCell(score: player.totalScore)
                .frame(width: 86)
        }
    }
}

struct TotalScoreCell: View {
    let score: Int?

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .shadow(color: .black, radius: 2, x: 0, y: 2)

            Text("\(score ?? 0)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

//struct ScoreboardView: View {
//    @EnvironmentObject var focusStatus: FocusStatus
//    @EnvironmentObject var userAuth: UserAuthModel
//    @State private var isAnimationEnabled = false
//    @State private var scrollPosition: CGFloat = 0
//    var players: [Player] = []
//    let gameID: Int
//    var body: some View {
//        VStack(spacing: 0) {
//            Spacer()
//            ScrollView(.horizontal) {
//                ScrollViewReader { scrollViewReaderProxy in
//                    VStack(spacing: 0) {
//                        Spacer()
//                        Divider()
//
//                        HStack(spacing: 0) {
//                            Text("HOLE")
//                                .font(.system(size: 25, weight: .bold))
//                                .foregroundColor(.black)
//                                .padding()
//                                .frame(width: 120, height: 60)
//                                .background(Color.white.opacity(0))
//                                .background(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .fill(Color.white)
//                                        .shadow(color: .black, radius: 1, x: 4, y:5)
//                                )
//
//                            ForEach(Range(1...9), id: \.self) { holeNumber in
//                                HoleCell(text: "\(holeNumber)")
//                                    .frame(width: 80, height: 49)
//                            }
//
//                            Text("TOTAL")
//                                .font(.system(size: 25, weight: .bold))
//                                .foregroundColor(.black)
//                                .frame(width: 90, height: 62)
//                                .background(Color.white.opacity(0.5))
//                                .background(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .fill(Color.white)
//                                        .shadow(color: .black, radius: 1, x: -5, y: 2)
//                                )
//                        }
//                        .padding([.bottom], 46)
//                        Divider()
//                        ForEach(players.indices, id: \.self) { playerIndex in
//                            PlayerRow(player: players[playerIndex])
//                                .padding(20)
//                                .frame(width: 70, height: 116)
//                        }
//
//                        Spacer()
//                    }
//                    .padding()
//                    .onAppear {
//                        scrollViewReaderProxy.scrollTo(150, anchor: .leading)
//                        // Move the ScrollView horizontally
//                        let targetX: CGFloat = 0 // Adjust the desired X position
//                        scrollPosition = targetX
//                        withAnimation(.easeInOut(duration: 0.5)) {
//                            scrollViewReaderProxy.scrollTo(targetX, anchor: .leading)
//                        }
////                        fetchGameData() /////fghjjfhdagedrgasdrtasdfgasdfadstasdasrtasdfasdfaserbasdraserbaserbsrba
//                    }
//                    .onChange(of: scrollPosition) { newPosition in
//                        withAnimation(.easeInOut(duration: 0.5)) {
//                            scrollViewReaderProxy.scrollTo(newPosition, anchor: .leading)
//                        }
//                    }
//                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//                        scrollViewReaderProxy.scrollTo(scrollPosition, anchor: .leading)
//                    }
//
//
//                    .id("scrollArea")
//                }
//
//
//
//                Spacer()
//            }
//            Spacer()
//            Text("Scoreboard")
//                .font(.title)
//                .fontWeight(.bold)
//                .foregroundColor(.black)
//                .frame(maxWidth: .infinity)
//                .padding()
//                .shadow(color: .gray, radius: 0, x: 0, y: 0)
//                .zIndex(1)
//        }.overlay(
//            Group {
//                if focusStatus.focusedCell != nil {
//                    Color.black.opacity(0.6)
//                        .ignoresSafeArea(.all, edges: .all)
//                        .animation(.easeIn)
//                }
//            }
//        )
//    }
//
//    struct HoleCell: View {
//        let text: String
//
//        var body: some View {
//            Text(text)
//                .font(.system(size: 74, weight: .bold))
//                .foregroundColor(.black)
//                .padding()
//                .frame(width: 80, height: 100, alignment: .bottom)
//        }
//    }
//
//    struct PlayerRow: View {
//            let player: Player
//            @EnvironmentObject var focusStatus: FocusStatus
//
//        var body: some View {
//            HStack(spacing: 0) {
//                Text(player.name)
//                    .font(.system(size: 18, weight: .regular))
//                    .foregroundColor(.black)
//                    .padding()
//                    .frame(width: 120, height:  49)
//                    .background(Color.white.opacity(0.5))
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.white)
//                            .shadow(color: .black, radius: 3, x: 15, y: 7)
//                    )
//
//                ForEach(player.scores, id: \.self) { score in
//                    ScoreCell(score: score)
//                        .frame(width: 80, height: 10)
//                }
//
//                TotalScoreCell(score: player.totalScore)
//                    .frame(width: 86)
//            }
//        }
//    }
//
//    struct ScoreCell: View {
//        let id = UUID() // to identify this view
//        let score: Int
//
//        @EnvironmentObject var focusStatus: FocusStatus
//
//        var isFocused: Bool {
//            id == focusStatus.focusedCell
//        }
//
//
//        var body: some View {
//            Button(action: {
//                withAnimation {
//                    if self.isFocused {
//                        self.focusStatus.focusedCell = nil
//                    } else {
//                        self.focusStatus.focusedCell = id
//                    }
//                }
//            }) {
//                Text("\(score)")
//                    .font(.system(size: isFocused ? 160 : 54, weight: .regular))
//                    .foregroundColor(score < 0 ? .blue : (score > 0 ? .red : .white))
//                    .padding()
//                    .frame(width: isFocused ? 280 : 80, height: isFocused ? 280 : 110)
//                    .background(
//                        RoundedRectangle(cornerRadius: 15)
//                            .fill(Color.white)
//                            .shadow(color: .black, radius: 2, x: 0, y: 2)
//                    )
//            }
//            .zIndex(isFocused ? 1 : 0)
//            .background(self.focusStatus.focusedCell == id ? Color.black.opacity(0.3) : Color.clear)
//        }
//    }
//
//
//
//    struct TotalScoreCell: View {
//        let score: Int?
//
//        var body: some View {
//            ZStack {
//                Circle()
//                    .fill(Color.blue)
//                    .frame(width: 40, height: 40)
//                    .shadow(color: .black, radius: 2, x: 0, y: 2)
//
//                Text("\(score ?? 0)")
//                    .font(.system(size: 18, weight: .bold))
//                    .foregroundColor(.white)
//            }
//        }
//    }
//
//    struct Player {
//        let name: String
//        var scores: [Int]
//
//        var totalScore: Int? {
//            scores.reduce(0, +)
//        }
//    }
//}
//
//struct ScoreboardView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScoreboardView(players: [
//            ScoreboardView.Player(name: "Player 1", scores: [-1, 0, 1, -2, 3, 0, 1, -1, 2]),
//            ScoreboardView.Player(name: "Player 2", scores: [0, -1, 2, -1, 1, -1, 0, 1, 0])
//        ], gameID: 1).environmentObject(FocusStatus())
//        .previewDevice("iPhone 12 Pro")
//    }
//}
//
//class FocusStatus: ObservableObject {
//    @Published var focusedCell: UUID? = nil
//}
//
//
///*
//
//    .background(
//        GeometryReader { geometry in
//            Path { path in
//                let width = geometry.size.width
//                let height = geometry.size.height
//                let streakCount = Int(width / 40) // Adjust the density of streaks here
//
//                for _ in 0..<streakCount {
//                    let startX = CGFloat.random(in: 0..<width)
//                    let startY = CGFloat.random(in: 0..<height)
//                    let endX = CGFloat.random(in: 0..<width)
//                    let endY = CGFloat.random(in: 0..<height)
//                    let color = Bool.random() ? Color.green : Color.blue.opacity(0.7)
//                    path.move(to: CGPoint(x: startX, y: startY))
//                    path.addLine(to: CGPoint(x: endX, y: endY))
//                }
//            }.stroke(Bool.random() ? Color.green.opacity(0.3) : Color.blue.opacity(0.2), lineWidth: 0.5)
//        }
//    )
//    .background(Color.gray.opacity(0.07))
//    .padding()
//*/
