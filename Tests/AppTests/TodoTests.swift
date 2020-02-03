@testable import App
import Crypto
import Vapor
import XCTest
import FluentPostgreSQL

extension Routes.Todos: TodosEndpoint { }

final class TodoTests: AppTesCase {

    private func deleteAllTodos() throws {
        let todos = Todo.query(on: try dbConnection()).all()
        try todos.wait().forEach { todo in
            try todo.delete(on: dbConnection()).wait()
        }
    }
    
    func testFetchTodo() throws {
        //let useCase = FetchTodoUseCase()
        //let allTodos = useCase.fetch().wait()
    }
    
    func testTodoDeletion() throws {
        let connection = try dbConnection()
        try deleteAllTodos()
        let authObject = try UserTokenMock.userToken(db: connection)

        
        let user = try authObject.user.get(on: connection).wait()
        let createUseCase = CreateTodoUseCase(user: user, db: connection)
        let newTodo = try createUseCase.createTodo(Todo(title: "Homework")).wait()

        let deleteTodoRequestContent = DeleteTodoRequestContent(
            token: authObject.string,
            body: DeleteTodoRequestBody(id: newTodo.id!)
        )
        let todoRequest = API.Todos<Routes.Todos>.delete(deleteTodoRequestContent)

        let response = try app.getResponse(request: try todoRequest.request())

        do {
            XCTAssertEqual(response.status.code, HTTPResponseStatus.ok.code)
        } catch {
            XCTFail("Failed decoding data: \(String(data: response.body.data ?? Data(), encoding: .utf8)!)")
        }
    }

    func testTodoCreation() throws {
        let connection = try dbConnection()
        try deleteAllTodos()
        
        let authObject = try UserTokenMock.userToken(db: connection)

        let createTodoRequestBody = CreateTodoRequestBody(title: "")
        let createTodoRequestContent = CreateTodoRequestContent(
            token: authObject.string,
            body: createTodoRequestBody
        )
        let todoRequest = API.Todos<Routes.Todos>.create(createTodoRequestContent)

        let response = try app.getResponse(request: try todoRequest.request())

        do {
            switch try todoRequest.parse(data: response.body.data) {
            case .create(let responseContent):
                XCTAssertGreaterThan(responseContent.id, 0)
            default:
                XCTFail("Failed parsing response")
            }
        } catch let responseError as ResponseError {
            XCTFail("Failed creating todo: \(responseError.reason)")
        } catch {
            XCTFail("Failed decoding data: \(String(data: response.body.data ?? Data(), encoding: .utf8)!)")
        }
    }
}
