//
//  FPL Insight
//  MyTeamModels.swift
//  Developed by Md Afser Uddin
//
struct SquadSlot: Identifiable, Codable, Equatable {
    let id: Int
    let role: SlotRole
    let index: Int
    var player: AllPlayerModel?

    var title: String {
        role.title
    }

    init(id: Int, role: SlotRole, index: Int, player: AllPlayerModel? = nil) {
        self.id = id
        self.role = role
        self.index = index
        self.player = player
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        role = try container.decode(SlotRole.self, forKey: .role)
        index = try container.decodeIfPresent(Int.self, forKey: .index) ?? 0
        player = try container.decodeIfPresent(AllPlayerModel.self, forKey: .player)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case role
        case index
        case player
    }
}

enum TeamFormation: String, CaseIterable, Identifiable, Codable {
    case fourFourTwo = "4-4-2"
    case threeFourThree = "3-4-3"
    case threeFiveTwo = "3-5-2"
    case fourThreeThree = "4-3-3"
    case fourFiveOne = "4-5-1"
    case fiveThreeTwo = "5-3-2"
    case fiveFourOne = "5-4-1"

    var id: String {
        rawValue
    }

    var defenders: Int {
        counts.defenders
    }

    var midfielders: Int {
        counts.midfielders
    }

    var forwards: Int {
        counts.forwards
    }

    private var counts: (defenders: Int, midfielders: Int, forwards: Int) {
        switch self {
        case .fourFourTwo:
            (4, 4, 2)
        case .threeFourThree:
            (3, 4, 3)
        case .threeFiveTwo:
            (3, 5, 2)
        case .fourThreeThree:
            (4, 3, 3)
        case .fourFiveOne:
            (4, 5, 1)
        case .fiveThreeTwo:
            (5, 3, 2)
        case .fiveFourOne:
            (5, 4, 1)
        }
    }
}

enum SlotRole: String, Codable {
    case goalkeeper = "GK"
    case defender = "DEF"
    case midfielder = "MID"
    case forward = "FWD"
    case bench = "BENCH"
    case benchGoalkeeper = "BENCH_GK"

    var title: String {
        switch self {
        case .benchGoalkeeper:
            "GK"
        default:
            rawValue
        }
    }

    var allowedPlayerPosition: String? {
        switch self {
        case .goalkeeper:
            "GK"
        case .defender:
            "DEF"
        case .midfielder:
            "MID"
        case .forward:
            "FWD"
        case .benchGoalkeeper:
            "GK"
        case .bench:
            nil
        }
    }
}

enum PlayerSearchState {
    case idle
    case loading
    case loaded([AllPlayerModel])
    case failed(String)
}
