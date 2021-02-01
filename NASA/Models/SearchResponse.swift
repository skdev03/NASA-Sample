import Foundation

struct SearchResponse: Codable {
    let collection: Collection
}

struct Collection: Codable {
    let version: String
    let href: String
    let items: [Item]
}

struct Item: Codable, Hashable {
    let links: [Link]?
    let href: String?
    let data: [ItemData]

    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }

    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.data == rhs.data
    }
}

struct Link: Codable, Hashable {
    let href: String
    let render: MediaType?
    let rel: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(href)
    }

    static func == (lhs: Link, rhs: Link) -> Bool {
        return lhs.href == rhs.href
    }
}

enum MediaType: String, Codable {
    case audio = "audio"
    case image = "image"
    case video = "video"
}

struct ItemData: Codable, Hashable {
    let nasaID: String
    let album: [String]?
    let keywords: [String]?
    let center: String
    let dateCreated: Date
    let description: String?
    let mediaType: MediaType
    let title: String
    let photographer: String?
    let location: String?

    enum CodingKeys: String, CodingKey {
        case nasaID = "nasa_id"
        case album, keywords, center
        case dateCreated = "date_created"
        case description
        case mediaType = "media_type"
        case title, photographer, location
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(nasaID)
    }

    static func == (lhs: ItemData, rhs: ItemData) -> Bool {
        return lhs.nasaID == rhs.nasaID
    }
}
