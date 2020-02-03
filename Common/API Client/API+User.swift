import Foundation
import HTTP

protocol UserEndpoint: APIEndpoint {
    static var users: String { get }
}

extension API {
    enum User<Endpoint: UserEndpoint> {
        case createUser(CreateUserRequestContent)
    }
}

extension API.User: APIRequest {

    enum Parser: APIResponseParser {
        case createUser(CreateUserResponseContent)
    }

    func request() throws -> HTTPRequest {
        switch self {
        case .createUser(let userRequest):
            return try .jsonPost(url: Endpoint.users, body: userRequest)
        }
    }
    
    func parseObject(data: Data) throws -> Parser {
        switch self {
        case .createUser:
            return Parser.createUser(try JSONEnvelope<CreateUserResponseContent>.envelope(data))
        }
    }
}

// MARK: - Request Content
struct CreateUserRequestContent: Codable {
    let name: String
    let email: String
    let password: String
    let verifyPassword: String
    init(name: String, email: String, password: String) {
        self.name = name
        self.email = email
        self.password = password
        self.verifyPassword = password
    }
}

// MARK: - Response Content
struct CreateUserResponseContent: Codable {
    let name: String
    let email: String
    let id: Int
}
