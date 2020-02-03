import Foundation
import HTTP

// MARK: - API
enum API { }


// MARK: - Protocols
protocol APIEndpoint { }
protocol APIResponseParser { }

protocol APIRequest {
    associatedtype Endpoint: APIEndpoint
    associatedtype Parser: APIResponseParser
    func request() throws -> HTTPRequest
    func parse(data: Data) throws -> Parser
    func parseObject(data: Data) throws -> Parser
}

extension APIRequest {
    func parse(data: Data) throws -> Parser {
        if let responseError = try? JSONDecoder().decode(ResponseError.self, from: data) {
            throw responseError
        }
        return try parseObject(data: data)
    }

    func parse(data: Data?) throws -> Parser {
        guard let data = data else { throw ParseError.dataIsEmpty }
        return try parse(data: data)
    }
}

// MARK: - Concrete Types
struct ResponseError: Codable, Error {
    let error: Bool
    let reason: String
}

enum ParseError: Error {
    case dataIsEmpty
    case notImplemented
}

enum JSONEnvelope<T: Codable> {
    typealias ParserEnvelope<T> = (Data) throws -> T
    static var envelope: ParserEnvelope<T> {
        { try JSONDecoder().decode(T.self, from: $0) }
    }
}

// MARK: - Extensions
extension HTTPHeaders {
    enum ContentType {
        case json
    }
    init(contentType: ContentType) {
        switch contentType {
        case .json:
            self.init([("Content-type", "application/json")])
        }
    }
}

extension HTTPBody {
    init<T: Codable>(_ obj: T) throws {
        self.init(data: try JSONEncoder().encode(obj))
    }
}

extension HTTPRequest {
    
    static func post(url: String, headers: HTTPHeaders, body: HTTPBody) -> Self {
        return HTTPRequest(method: .POST, url: url, headers: headers, body: body)
    }
    
    static func delete(url: String, authToken: String? = nil) throws -> Self {
        var headers = HTTPHeaders()
        if let authToken = authToken {
            headers.bearerAuthorization = BearerAuthorization(token: authToken)
        }
        return HTTPRequest(method: .DELETE, url: url, headers: headers)
    }
    
    static func jsonPost<T: Codable>(url: String, body: T, authToken: String? = nil) throws -> Self {
        var headers = HTTPHeaders(contentType: .json)
        if let authToken = authToken {
            headers.bearerAuthorization = BearerAuthorization(token: authToken)
        }
        return .post(
            url: url,
            headers: headers,
            body: try HTTPBody(body)
        )
    }
    
}
