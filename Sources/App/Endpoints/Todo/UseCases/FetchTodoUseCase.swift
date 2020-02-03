import Vapor


struct FetchTodoUseCase {
    let user: User
    let db: DatabaseConnectable

    func fetch() throws -> Future<[Todo]> {
        Todo.query(on: db).all()
    }
}
