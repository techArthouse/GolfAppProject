//
//  GameModel.swift
//  ScoreCards
//
//  Created by Arturo Aguilar on 6/23/23.
//

import Foundation

// MARK: - Game

struct Game: Codable, Identifiable {
    let id: Int
    let tournamentFlag: Int?
    let buyIn: Double?
    let numRounds: Int?

    enum CodingKeys: String, CodingKey {
        case id = "game_id"
        case tournamentFlag = "tournament_flag"
        case buyIn = "buy_in"
        case numRounds = "num_rounds"
    }
}

// MARK: - Player

struct Player: Codable, Identifiable {
    let id: Int
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id = "player_id"
        case name = "player_name"
    }
}

// MARK: - Course

struct Course: Codable, Identifiable {
    let id: Int
    let name: String?
    let rating: Double?
    let slopeRating: Int?
    let par: Int?

    enum CodingKeys: String, CodingKey {
        case id = "course_id"
        case name = "course_name"
        case rating = "course_rating"
        case slopeRating = "slope_rating"
        case par = "par"
    }
}

// MARK: - Round

struct Round: Codable, Identifiable {
    let id: Int
    let gameId: Int
    let playerId: Int
    let courseId: Int
    let roundNum: Int?
    let totalScore: Int?
    let handicap: Double?

    enum CodingKeys: String, CodingKey {
        case id = "round_id"
        case gameId = "game_id"
        case playerId = "player_id"
        case courseId = "course_id"
        case roundNum = "round_num"
        case totalScore = "total_score"
        case handicap = "handicap"
    }
}

// MARK: - GamePlayer

struct GamePlayer: Codable, Identifiable, Hashable {
    var id: String { "\(gameId)-\(playerId)" }
    let gameId: Int?
    let playerId: Int
    let playerName: String
    let roundId: Int?
    let roundNum: Int
    let totalScore: Int?
    let handicap: String?

    enum CodingKeys: String, CodingKey {
        case gameId = "game_id"
        case playerId = "player_id"
        case playerName = "player_name"
        case roundId = "round_id"
        case roundNum = "round_num"
        case totalScore = "total_score"
        case handicap
    }
}

struct PlayerData: Decodable {
    let playerId: Int
    let playerName: String
    let roundId: Int?
    let roundNum: Int
    let totalScore: Int?
    let handicap: String?
    
    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case playerName = "player_name"
        case roundId = "round_id"
        case roundNum = "round_num"
        case totalScore = "total_score"
        case handicap
    }
}

// MARK: - FullGameData

struct FullGameData: Codable, Identifiable {
    var id: String { "\(gameId)-\(playerId)-\(courseId)-\(String(describing: roundNum))" }
    let gameId: Int
    let tournamentFlag: Bool?
    let buyIn: Double?
    let numRounds: Int
    let playerId: Int
    let playerName: String
    let roundNum: Int?
    let courseId: Int
    let courseName: String
    let courseRating: String
    let slopeRating: Double
    let par: Int
    let totalScore: Int
    let handicap: Int?
    
    enum CodingKeys: String, CodingKey {
        case gameId = "game_id"
        case tournamentFlag = "tournament_flag"
        case buyIn = "buy_in"
        case numRounds = "num_rounds"
        case playerId = "player_id"
        case playerName = "player_name"
        case roundNum = "round_num"
        case courseId = "course_id"
        case courseName = "course_name"
        case courseRating = "course_rating"
        case slopeRating = "slope_rating"
        case par = "par"
        case totalScore = "total_score"
        case handicap = "handicap"
    }
}

struct BackendResponse: Codable {
    let message: String
    let error: String
    let player_id: Int?
    let host_id: Int?
}


struct TokenVerificationResult: Codable {
    let aud: String?
    let error: String?
    let playerId: Int?
    
    enum CodingKeys: String, CodingKey {
        case aud
        case error
        case playerId = "player_id"
    }
}

struct InvitedPlayer: Codable {
    let playerId: Int
    let playerName: String
    let userId: Int
    let handicap: String
    
    enum CodingKeys: String, CodingKey {
        case playerId = "player_id"
        case playerName = "player_name"
        case userId = "user_id"
        case handicap
    }
}

struct MultipleInvitesResponse: Codable {
    let invited: [InvitedPlayer]
}
