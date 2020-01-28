import Foundation
import HTTP

protocol UserEndpoint: APIEndpoint {
    static var users: String { get }
}

extension API {
    enum User<Endpoint: UserEndpoint> {
        case createUser(CreateUserRequest)
    }
}

extension API.User: APIRequest {
    func request() throws -> HTTPRequest {
        switch self {
        case .createUser(let userRequest):
            return try .jsonPost(url: Endpoint.users, body: userRequest)
        }
    }
    
    enum Parser: APIResponseParser {
        case createUser(CreateUserResponse)
    }
    
    func parseObject(data: Data) throws -> Parser {
        switch self {
        case .createUser:
            return Parser.createUser(try JSONEnvelope<CreateUserResponse>.envelope(data))
        }
    }
}

struct CreateUserRequest: Codable {
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

struct CreateUserResponse: Codable {
    let name: String
    let email: String
    let id: Int
}
