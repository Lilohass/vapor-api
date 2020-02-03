import Vapor


/// Controls basic CRUD operations on `Todo`s.
final class TodoController {
    /// Returns a list of all `Todo`s.
    func index(_ req: Request) throws -> Future<[Todo]> {
        let useCase = FetchTodoUseCase(
            user: try req.requireAuthenticated(User.self),
            db: req
        )
        return try useCase.fetch()
    }

    /// Saves a decoded `Todo` to the database.
    func create(_ req: Request) throws -> Future<Todo> {
        // fetch auth'd user
        let useCase = CreateTodoUseCase(
            user: try req.requireAuthenticated(User.self),
            db: req
        )
        return try useCase.createTodo(req)
    }

    /// Deletes a parameterized `Todo`.
    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        let useCase = DeleteTodoUseCase(
            user: try req.requireAuthenticated(User.self),
            db: req
        )
        return try useCase.deleteTodo(req).transform(to: .ok)
    }
}
