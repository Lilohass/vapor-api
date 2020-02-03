import Foundation
import HTTP

protocol TodosEndpoint: APIEndpoint {
    static var todos: String { get }
    static func todo(with id: Int) -> String
}

extension TodosEndpoint {
    static func todo(with id: Int) -> String {
        "\(todos)/\(id)"
    }
}

extension API {
    enum Todos<Endpoint: TodosEndpoint> {
        case create(CreateTodoRequestContent)
        case delete(DeleteTodoRequestContent)
    }
}

extension API.Todos: APIRequest {

    enum Parser: APIResponseParser {
        case create(CreateTodoResponseContent)
    }

    func request() throws -> HTTPRequest {
        switch self {
        case .create(let createTodoRequestContent):
            return try .jsonPost(url: Endpoint.todos,
                                 body: createTodoRequestContent.body,
                                 authToken: createTodoRequestContent.token)
        case .delete(let deleteTodoRequestContent):
            return try .delete(url: Endpoint.todo(with: deleteTodoRequestContent.body.id),
                               authToken: deleteTodoRequestContent.token)
        }
    }

    func parseObject(data: Data) throws -> Parser {
        switch self {
        case .create:
            return Parser.create(try JSONEnvelope<CreateTodoResponseContent>.envelope(data))
        case .delete:
            throw ParseError.notImplemented
        }
    }
}

protocol RequestWithToken {
    var token: String { get }
}

// MARK: - Request Content
struct CreateTodoRequestBody: Codable {
    let title: String
}

struct CreateTodoRequestContent: Codable, RequestWithToken {
    let token: String
    let body: CreateTodoRequestBody
}

struct DeleteTodoRequestBody: Codable {
    let id: Int
}

struct DeleteTodoRequestContent: Codable, RequestWithToken {
    let token: String
    let body: DeleteTodoRequestBody
    
}

// MARK: - Response Content
struct CreateTodoResponseContent: Codable {
    let id: Int
}
