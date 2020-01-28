import Foundation
import HTTP

protocol TodosEndpoint: APIEndpoint {
    static var todos: String { get }
}

extension API {
    enum Todos<Endpoint: TodosEndpoint> {
        case createTodo(CreateTodoRequest)
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
        case createTodo(CreateTodoResponse)
    }

    func parseObject(data: Data) throws -> Parser {
        switch self {
        case .createTodo:
            return Parser.createTodo(try JSONEnvelope<CreateTodoResponse>.envelope(data))
        }
    }
}

struct CreateTodoRequest: Codable {
    let name: String
}

struct CreateTodoResponse: Codable {
    let id: Int
}
