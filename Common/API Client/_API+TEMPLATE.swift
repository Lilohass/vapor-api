/*
import Foundation
import HTTP

// Instructions
// Example: Endpoint name is `Cars`
// Find and replace all "--" by "Car"
// Find and replace all "__" by "car"

protocol --sEndpoint: APIEndpoint {
    static var __: String { get }
}

extension API {
    enum --s<Endpoint: --sEndpoint> {
        case create--(Create--RequestContent)
    }
}

extension API.--s: APIRequest {

    enum Parser: APIResponseParser {
        case create--(Create--ResponseContent)
    }

    func request() throws -> HTTPRequest {
        switch self {
        case .create--(let create--Request):
            return try .jsonPost(url: Endpoint.__,
                                 body: create--Request.body,
                                 authToken: create--Request.token)
        }
    }

    func parseObject(data: Data) throws -> Parser {
        switch self {
        case .create--:
            return Parser.create--(try JSONEnvelope<Create--ResponseContent>.envelope(data))
        }
    }
}

// MARK: - Request Content
struct Create--RequestBody: Codable {
    let title: String
}

struct Create--RequestContent: Codable {
    let token: String
    let body: Create--RequestBody
}

// MARK: - Response Content
struct Create--ResponseContent: Codable {
    let id: Int
}
*/
