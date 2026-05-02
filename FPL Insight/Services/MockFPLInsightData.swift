//
//  FPL Insight
//  MockFPLInsightData.swift
//  Developed by Md Afser Uddin
//
import Foundation

enum MockFPLInsightData {
    static let season = 2026
    static let gameweek = 35

    static let bestXI = BestXIResponse(
        season: season,
        gameweek: gameweek,
        formation: Formation(goalkeepers: 2, defenders: 5, midfielders: 5, forwards: 3),
        totalPredictedPoints: bestXIPlayers.reduce(0) { $0 + $1.predictedPoints },
        players: bestXIPlayers
    )

    static func topPlayers(limit: Int) -> TopPlayerResponse {
        TopPlayerResponse(
            season: season,
            gameweek: gameweek,
            limit: limit,
            players: allPlayers
                .sorted { $0.totalPoints > $1.totalPoints }
                .prefix(limit)
                .map {
                    TopPlayer(
                        name: $0.name,
                        position: $0.position,
                        team: $0.team,
                        opponentTeamName: $0.opponentTeamName,
                        totalPoints: $0.totalPoints,
                        imageURL: $0.imageURL
                    )
                }
        )
    }

    static func allPlayers(limit: Int, q: String?, position: String?) -> AllPlayersResponse {
        let searchText = q?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        let filteredPlayers = allPlayers.filter { player in
            let matchesPosition = position == nil || player.position == position
            let matchesQuery = searchText?.isEmpty != false ||
                player.name.lowercased().contains(searchText ?? "") ||
                player.team.lowercased().contains(searchText ?? "")

            return matchesPosition && matchesQuery
        }

        return AllPlayersResponse(
            season: season,
            gameweek: gameweek,
            query: q,
            limit: limit,
            players: Array(filteredPlayers.prefix(limit))
        )
    }

    private static let bestXIPlayers: [PredictedPlayer] = [
        PredictedPlayer(name: "David Raya", position: "GK", team: "Arsenal", opponentTeamName: "Brighton", predictedPoints: 5, imageURL: nil),
        PredictedPlayer(name: "Bernd Leno", position: "GK", team: "Fulham", opponentTeamName: "West Ham", predictedPoints: 4, imageURL: nil),
        PredictedPlayer(name: "Virgil van Dijk", position: "DEF", team: "Liverpool", opponentTeamName: "Wolves", predictedPoints: 5, imageURL: nil),
        PredictedPlayer(name: "Gabriel Magalhaes", position: "DEF", team: "Arsenal", opponentTeamName: "Brighton", predictedPoints: 5, imageURL: nil),
        PredictedPlayer(name: "James Tarkowski", position: "DEF", team: "Everton", opponentTeamName: "Burnley", predictedPoints: 5, imageURL: nil),
        PredictedPlayer(name: "Vitalii Mykolenko", position: "DEF", team: "Everton", opponentTeamName: "Burnley", predictedPoints: 5, imageURL: nil),
        PredictedPlayer(name: "Matheus Nunes", position: "DEF", team: "Man City", opponentTeamName: "Nott'm Forest", predictedPoints: 5, imageURL: nil),
        PredictedPlayer(name: "Mohamed Salah", position: "MID", team: "Liverpool", opponentTeamName: "Wolves", predictedPoints: 7, imageURL: nil),
        PredictedPlayer(name: "Bukayo Saka", position: "MID", team: "Arsenal", opponentTeamName: "Brighton", predictedPoints: 6, imageURL: nil),
        PredictedPlayer(name: "Cole Palmer", position: "MID", team: "Chelsea", opponentTeamName: "Aston Villa", predictedPoints: 6, imageURL: nil),
        PredictedPlayer(name: "Morgan Gibbs-White", position: "MID", team: "Nott'm Forest", opponentTeamName: "Man City", predictedPoints: 6, imageURL: nil),
        PredictedPlayer(name: "Antoine Semenyo", position: "MID", team: "Bournemouth", opponentTeamName: "Leeds", predictedPoints: 6, imageURL: nil),
        PredictedPlayer(name: "Joao Pedro", position: "FWD", team: "Chelsea", opponentTeamName: "Aston Villa", predictedPoints: 7, imageURL: nil),
        PredictedPlayer(name: "Erling Haaland", position: "FWD", team: "Man City", opponentTeamName: "Nott'm Forest", predictedPoints: 6, imageURL: nil),
        PredictedPlayer(name: "Hugo Ekitike", position: "FWD", team: "Liverpool", opponentTeamName: "Wolves", predictedPoints: 6, imageURL: nil)
    ]

    private static let allPlayers: [AllPlayerModel] = [
        AllPlayerModel(apiID: 1, name: "Mohamed Salah", position: "MID", team: "Liverpool", opponentTeamName: "Wolves", price: 13.2, totalPoints: 248, imageURL: nil, predictedPoints: 7),
        AllPlayerModel(apiID: 2, name: "Erling Haaland", position: "FWD", team: "Man City", opponentTeamName: "Nott'm Forest", price: 14.1, totalPoints: 221, imageURL: nil, predictedPoints: 6),
        AllPlayerModel(apiID: 3, name: "Cole Palmer", position: "MID", team: "Chelsea", opponentTeamName: "Aston Villa", price: 10.9, totalPoints: 219, imageURL: nil, predictedPoints: 6),
        AllPlayerModel(apiID: 4, name: "Bukayo Saka", position: "MID", team: "Arsenal", opponentTeamName: "Brighton", price: 10.1, totalPoints: 205, imageURL: nil, predictedPoints: 6),
        AllPlayerModel(apiID: 5, name: "Ollie Watkins", position: "FWD", team: "Aston Villa", opponentTeamName: "Chelsea", price: 9.0, totalPoints: 189, imageURL: nil, predictedPoints: 5),
        AllPlayerModel(apiID: 6, name: "Bruno Fernandes", position: "MID", team: "Man United", opponentTeamName: "Spurs", price: 8.6, totalPoints: 181, imageURL: nil, predictedPoints: 5),
        AllPlayerModel(apiID: 7, name: "Son Heung-min", position: "MID", team: "Spurs", opponentTeamName: "Man United", price: 9.8, totalPoints: 176, imageURL: nil, predictedPoints: 5),
        AllPlayerModel(apiID: 8, name: "Alexander Isak", position: "FWD", team: "Newcastle", opponentTeamName: "Leicester", price: 9.5, totalPoints: 174, imageURL: nil, predictedPoints: 5),
        AllPlayerModel(apiID: 9, name: "Virgil van Dijk", position: "DEF", team: "Liverpool", opponentTeamName: "Wolves", price: 6.4, totalPoints: 164, imageURL: nil, predictedPoints: 5),
        AllPlayerModel(apiID: 10, name: "Gabriel Magalhaes", position: "DEF", team: "Arsenal", opponentTeamName: "Brighton", price: 6.2, totalPoints: 158, imageURL: nil, predictedPoints: 5),
        AllPlayerModel(apiID: 11, name: "David Raya", position: "GK", team: "Arsenal", opponentTeamName: "Brighton", price: 5.6, totalPoints: 153, imageURL: nil, predictedPoints: 5),
        AllPlayerModel(apiID: 12, name: "Alisson Becker", position: "GK", team: "Liverpool", opponentTeamName: "Wolves", price: 5.5, totalPoints: 149, imageURL: nil, predictedPoints: 4),
        AllPlayerModel(apiID: 13, name: "Bernd Leno", position: "GK", team: "Fulham", opponentTeamName: "West Ham", price: 5.0, totalPoints: 145, imageURL: nil, predictedPoints: 4),
        AllPlayerModel(apiID: 14, name: "James Tarkowski", position: "DEF", team: "Everton", opponentTeamName: "Burnley", price: 5.1, totalPoints: 142, imageURL: nil, predictedPoints: 5),
        AllPlayerModel(apiID: 15, name: "Vitalii Mykolenko", position: "DEF", team: "Everton", opponentTeamName: "Burnley", price: 4.8, totalPoints: 136, imageURL: nil, predictedPoints: 5),
        AllPlayerModel(apiID: 16, name: "Matheus Nunes", position: "DEF", team: "Man City", opponentTeamName: "Nott'm Forest", price: 5.0, totalPoints: 132, imageURL: nil, predictedPoints: 5),
        AllPlayerModel(apiID: 17, name: "Trent Alexander-Arnold", position: "DEF", team: "Liverpool", opponentTeamName: "Wolves", price: 7.1, totalPoints: 131, imageURL: nil, predictedPoints: 4),
        AllPlayerModel(apiID: 18, name: "Morgan Gibbs-White", position: "MID", team: "Nott'm Forest", opponentTeamName: "Man City", price: 6.6, totalPoints: 128, imageURL: nil, predictedPoints: 6),
        AllPlayerModel(apiID: 19, name: "Antoine Semenyo", position: "MID", team: "Bournemouth", opponentTeamName: "Leeds", price: 6.4, totalPoints: 125, imageURL: nil, predictedPoints: 6),
        AllPlayerModel(apiID: 20, name: "Joao Pedro", position: "FWD", team: "Chelsea", opponentTeamName: "Aston Villa", price: 7.5, totalPoints: 121, imageURL: nil, predictedPoints: 7),
        AllPlayerModel(apiID: 21, name: "Hugo Ekitike", position: "FWD", team: "Liverpool", opponentTeamName: "Wolves", price: 7.0, totalPoints: 119, imageURL: nil, predictedPoints: 6),
        AllPlayerModel(apiID: 22, name: "Dominic Solanke", position: "FWD", team: "Spurs", opponentTeamName: "Man United", price: 7.7, totalPoints: 116, imageURL: nil, predictedPoints: 5),
        AllPlayerModel(apiID: 23, name: "Milos Kerkez", position: "DEF", team: "Bournemouth", opponentTeamName: "Leeds", price: 5.2, totalPoints: 108, imageURL: nil, predictedPoints: 4),
        AllPlayerModel(apiID: 24, name: "Matz Sels", position: "GK", team: "Nott'm Forest", opponentTeamName: "Man City", price: 5.1, totalPoints: 106, imageURL: nil, predictedPoints: 3)
    ]
}
