import Foundation
import HTTP

protocol LoginEndpoint: APIEndpoint {
    static var login: String { get }
}

extension API {
    enum Login<Endpoint: LoginEndpoint> {
        case login(LoginRequest)
    }
}

extension API.Login: APIRequest {
    func request() throws -> HTTPRequest {
        switch self {
        case .login(let loginRequest):
            return try .jsonPost(url: Endpoint.login, body: loginRequest)
        }
    }

    enum Parser: APIResponseParser {
        case login(LoginResponse)
    }

    func parseObject(data: Data) throws -> Parser {
        switch self {
        case .login:
            return Parser.login(try JSONEnvelope<LoginResponse>.envelope(data))
        }
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let id: Int
    let string: String
    let userID: Int
    let expiresAt: Date
}
