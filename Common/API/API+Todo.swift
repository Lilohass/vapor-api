import Foundation
import HTTP

protocol TodosEndpoint: APIEndpoint {
    static var todos: String { get }
}

extension API {
    enum Todos<Endpoint: TodosEndpoint> {
        case createTodo(CreateTodoRequestContent)
    }
}

extension API.Todos: APIRequest {
    func request() throws -> HTTPRequest {
        switch self {
        case .createTodo(let createTodoRequest):
            return try .jsonPost(url: Endpoint.todos, body: createTodoRequest)
        }
    }
    
    enum Parser: APIResponseParser {
        case createTodo(CreateTodoResponseContent)
    }

    func parseObject(data: Data) throws -> Parser {
        switch self {
        case .createTodo:
            return Parser.createTodo(try JSONEnvelope<CreateTodoResponseContent>.envelope(data))
        }
    }
}

struct CreateTodoRequestContent: Codable {
    let name: String
}

struct CreateTodoResponseContent: Codable {
    let id: Int
}
