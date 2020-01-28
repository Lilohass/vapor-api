import FluentPostgreSQL
import Vapor
@testable import App

enum UserTestGenerator {
    enum UserTokenError: Error {
        case failed
    }
    static func userToken(db: DatabaseConnectable) throws -> UserToken {
        let email = "mail@mail.com"
        let password = "1234"
        let createUserRequestContent = App.CreateUserRequestContent(name: "William",
                                                                    email: email,
                                                                    password: password,
                                                                    verifyPassword: password)
        let createUserUseCase = CreateUserUseCase(user: createUserRequestContent, db: db)
        let _ = try? createUserUseCase.createUser().wait()
        
        guard let userResult = try? User.query(on: db).filter(\.email == email).all().wait().first, let user = userResult else {
            throw UserTokenError.failed
        }
        
        let authenticateUseCase = AuthenticateUserUseCase(user: user, db: db)
        let auth = try authenticateUseCase.authenticateUser().wait()
        guard auth.id != nil else {
            throw UserTokenError.failed
        }
        return auth
    }
}
