import Foundation
import HTTP

protocol LoginEndpoint: APIEndpoint {
    static var login: String { get }
}

extension API {
    enum Login<Endpoint: LoginEndpoint> {
        case login(LoginRequestContent)
    }
}

extension API.Login: APIRequest {

    enum Parser: APIResponseParser {
        case login(LoginResponseContent)
    }

    func request() throws -> HTTPRequest {
        switch self {
        case .login(let loginRequest):
            var headers = HTTPHeaders()
            headers.basicAuthorization = BasicAuthorization(username: loginRequest.email, password: loginRequest.password)
            return .post(url: Endpoint.login, headers: headers, body: HTTPBody())
        }
    }

    func parseObject(data: Data) throws -> Parser {
        switch self {
        case .login:
            return Parser.login(try JSONEnvelope<LoginResponseContent>.envelope(data))
        }
    }
}

// MARK: - Request Content
struct LoginRequestContent: Codable {
    let email: String
    let password: String
}

// MARK: - Response Content
struct LoginResponseContent: Codable {
    let id: Int
    let string: String
    let userID: Int
    let expiresAt: Date
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        string = try container.decode(String.self, forKey: .string)
        userID = try container.decode(Int.self, forKey: .userID)

        let dateString = try container.decode(String.self, forKey: .expiresAt)
        let formatter = DateFormatter.iso8601Full
        if let date = formatter.date(from: dateString) {
            expiresAt = date
        } else {
            expiresAt = Date()
            /*throw DecodingError.dataCorruptedError(forKey: .expiresAt,
                                                   in: container,
                                                   debugDescription: "Date string does not match format expected by formatter.")*/
        }
    }
}

extension DateFormatter {
  static let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.Z"
    return formatter
  }()
}
