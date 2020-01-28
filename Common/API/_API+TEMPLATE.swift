import Foundation
import HTTP

protocol __Endpoint: APIEndpoint {
    static var __: String { get }
}

extension API {
    enum __<Endpoint: __Endpoint> {
        case create__(Create__Request)
    }
}

extension API.__: APIRequest {
    func request() throws -> HTTPRequest {
        switch self {
        case .create__(let create__Request):
            return try .jsonPost(url: Endpoint.__, body: create__Request)
        }
    }
    
    enum Parser: APIResponseParser {
        case create__(Create__Response)
    }

    func parseObject(data: Data) throws -> Parser {
        switch self {
        case .create__:
            return Parser.create__(try JSONEnvelope<Create__Response>.envelope(data))
        }
    }
}

struct Create__Request: Codable {
    let name: String
}

struct Create__Response: Codable {
    let id: Int
}
