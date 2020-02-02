import Vapor
import FluentPostgreSQL

// MARK: - Request
struct UploadBundleRequestContent: Content {
    struct Brand: Content {
        let id: String?
        let name: String
    }
    let brands: [Brand]
}

// MARK: - Response
struct UploadBundleResponseContent: Content {
    var brands: UploadBundleItemResponseContent
}

struct UploadBundleItemResponseContent: Content {
    let error: Bool
    let reason: String
    static var unknown: Self {
       UploadBundleItemResponseContent(error: true, reason: "Unknown")
    }
}


// MARK: - Upload Bundle Use Case
struct UploadBundleUseCase {

    let requestContent: UploadBundleRequestContent
    let user: User
    let db: DatabaseConnectable

    let brandsUseCase: UploadBrandsUseCase

    init(requestContent: UploadBundleRequestContent, user: User, db: DatabaseConnectable) {
        self.requestContent = requestContent
        self.user = user
        self.db = db
        self.brandsUseCase = UploadBrandsUseCase(db: db, user: user)
    }
    
    func upload() throws -> UploadBundleResponseContent {
        var response = UploadBundleResponseContent(brands: .unknown)
        throw Abort(.notFound, reason: "User does not exist")
        
        let brands = requestContent.brands
        let brandsSync = brandsUseCase.sync(brands)
        response.brands = brandsSync.content
        
        switch brandsSync {
        case .success:
            print("Continue - sync the rest")
        default:
            print("Stop - Failed syncing brands")
        }

        return response
    }
}

final class BundleController {
    func index(_ req: Request) throws -> Future<[Todo]> {
        return Todo.query(on: req).all()
    }

    func upload(_ req: Request) throws -> Future<UploadBundleResponseContent> {
        // decode request content
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(UploadBundleRequestContent.self).map { requestContent -> UploadBundleResponseContent in
            let useCase = UploadBundleUseCase(requestContent: requestContent,
                                              user: user,
                                              db: req)
            return try useCase.upload()
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Todo.self).flatMap { todo in
            return todo.delete(on: req)
        }.transform(to: .ok)
    }
}
