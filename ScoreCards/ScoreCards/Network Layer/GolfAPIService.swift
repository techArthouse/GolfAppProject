//
//  GolfAPIService.swift
//  ScoreCards
//
//  Created by Arturo Aguilar on 6/23/23.
//

import Foundation

enum GolfAPIError: Error {
    case responseProblem
    case decodingProblem
    case encodingProblem
    case noData
    case invalidURL
}

class GolfAPIService {

    static let shared = GolfAPIService()

    let baseURL = URL(string: "http://localhost:5001")!

    func post<T: Codable>(endpoint: String, parameters: [String: Any], completion: @escaping (Result<T, Error>) -> Void) {
        let url = baseURL.appendingPathComponent(endpoint)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.invalidResponseData))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func invitePlayer(gameId: Int, playerId: Int, completion: @escaping (Result<String, Error>) -> Void) {
        let endpoint = "gameplayer"

        let parameters: [String: Any] = [
            "game_id": gameId,
            "player_id": playerId
        ]

        post(endpoint: endpoint, parameters: parameters) { (result: Result<[String: String], Error>) in
            switch result {
            case .success(let response):
                if let message = response["message"] {
                    completion(.success(message))
                } else if let error = response["error"] {
                    completion(.failure(GolfAPIError.responseProblem))
                } else {
                    completion(.failure(GolfAPIError.decodingProblem))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    
    func fetchFullGameData(completion: @escaping (Result<[FullGameData], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("fullgamedata")

        URLSession.shared.dataTask(with: url) { data, _, error in
//            print(data?.debugDescription)
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                do {
                    let fullGameData = try JSONDecoder().decode([FullGameData].self, from: data)
                    completion(.success(fullGameData))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func fetchGames(completion: @escaping (Result<[Game], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("games")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                do {
                    let games = try JSONDecoder().decode([Game].self, from: data)
                    completion(.success(games))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func fetchPlayers(completion: @escaping (Result<[Player], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("players")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                do {
                    let players = try JSONDecoder().decode([Player].self, from: data)
                    completion(.success(players))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func fetchCourses(completion: @escaping (Result<[Course], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("courses")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                do {
                    let courses = try JSONDecoder().decode([Course].self, from: data)
                    completion(.success(courses))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func fetchRounds(completion: @escaping (Result<[Round], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("rounds")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                do {
                    let rounds = try JSONDecoder().decode([Round].self, from: data)
                    completion(.success(rounds))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func fetchGamePlayers(completion: @escaping (Result<[GamePlayer], Error>) -> Void) {
        let url = baseURL.appendingPathComponent("gameplayers")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                do {
                    let gamePlayers = try JSONDecoder().decode([GamePlayer].self, from: data)
                    completion(.success(gamePlayers))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // Continue with similar methods for other endpoints you may have.
    func createGame(name: String, numRounds: Int, deadline: String, tournamentFlag: Bool, buyIn: Double, playerId: Int, completion: @escaping (Result<Int, Error>) -> Void) {
        let endpoint = "game"

        let parameters: [String: Any] = [
            "name": name,
            "num_rounds": numRounds,
            "deadline": deadline,
            "is_tournament": tournamentFlag,
            "buy_in": buyIn,
            "host_id": playerId  // Updated: Change "player_id" to "host_id"
        ]

        post(endpoint: endpoint, parameters: parameters) { (result: Result<GameCreated, Error>) in
            switch result {
            case .success(let gameCreated):
                completion(.success(gameCreated.gameId))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    
    func fetchGameData(gameID: Int) {
        // Make API call to fetch game data
        // Example:
         let url = URL(string: "http://localhost:5001/game/\(gameID)")
        // Perform URLSession data task and handle the response
    }
    
    func invitePlayersByEmail(gameId: Int, emailEntries: [EmailEntry], completion: @escaping (Result<[InvitedPlayer], Error>) -> Void) {
        let endpoint = "gameplayer/multiple"

        let emails = emailEntries.map { $0.email }
        let parameters: [String: Any] = [
            "game_id": gameId,
            "emails": emails
        ]

        post(endpoint: endpoint, parameters: parameters) { (result: Result<MultipleInvitesResponse, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.invited))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    
    static func getGameHost(gameId: Int, completion: @escaping (Result<Int?, Error>) -> Void) {
        guard let url = URL(string: "http://localhost:5001/game/\(gameId)/host") else {
            completion(.failure(GolfAPIError.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(GolfAPIError.noData))
                return
            }

            do {
                let res = try JSONDecoder().decode(BackendResponse.self, from: data)
                completion(.success(res.host_id))
            } catch {
                completion(.failure(error))
            }
        }
        .resume()
    }


    enum NetworkError: Error {
        case invalidURL
        case invalidRequestBody
        case invalidResponseData
        case jsonDecodingError
    }

}

struct GameCreated: Codable, Identifiable {
    var id: String { "\(gameId)" }
    let gameId: Int

    enum CodingKeys: String, CodingKey {
        case gameId = "game_id"
    }
}
