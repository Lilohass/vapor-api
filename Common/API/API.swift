import Foundation
import HTTP

// MARK: - Concrete Types
enum API { }

struct ResponseError: Codable {
    let error: Bool
    let reason: String
}

// MARK: - Protocols
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
}

extension ResponseError: Error {
    
}

enum ParseError: Error {
    case dataIsEmpty
    case notImplemented
}

extension APIRequest {
    func parse(data: Data?) throws -> Parser {
        guard let data = data else {
            throw ParseError.dataIsEmpty
        }
        return try parse(data: data)
    }
}

protocol APIEndpoint { }
protocol APIResponseParser { }



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
    
    static private func post(url: String, headers: HTTPHeaders, body: HTTPBody) -> Self {
        return HTTPRequest(method: .POST, url: url, headers: headers, body: body)
    }
    
    static func jsonPost<T: Codable>(url: String, body: T) throws -> Self {
        return .post(
            url: url,
            headers: HTTPHeaders(contentType: .json),
            body: try HTTPBody(body)
        )
    }
}
