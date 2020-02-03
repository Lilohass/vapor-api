import Vapor

struct DeleteTodoUseCase {
    let user: User
    let db: DatabaseConnectable

    func deleteTodo(_ todo: Todo) throws -> Future<Void> {
        todo.delete(on: self.db)
    }
}


// MARK: - Helper
extension DeleteTodoUseCase {
    func deleteTodo(_ request: Request) throws -> Future<Void> {
        try request.parameters.next(Todo.self).flatMap { todo in
            try self.deleteTodo(todo)
        }
    }
}
