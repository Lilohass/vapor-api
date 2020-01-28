import Foundation
import HTTP

protocol __Endpoint: APIEndpoint {
    static var __: String { get }
}

extension API {
    enum __<Endpoint: __Endpoint> {
        case create__(Create__RequestContent)
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
        case create__(Create__ResponseContent)
    }

    func parseObject(data: Data) throws -> Parser {
        switch self {
        case .create__:
            return Parser.create__(try JSONEnvelope<Create__ResponseContent>.envelope(data))
        }
    }
}

struct Create__RequestContent: Codable {
    let name: String
}

struct Create__ResponseContent: Codable {
    let id: Int
}
