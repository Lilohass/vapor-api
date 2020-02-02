import Vapor
import FluentPostgreSQL

// MARK: - Brands Use Case
struct UploadBrandsUseCase: SyncUseCase {

    typealias Object = [UploadBundleRequestContent.Brand]

    let db: DatabaseConnectable
    let user: User

    func sync(_ object: Object) -> OperationResult {
        //return OperationResult.failure(GeneralSyncError(localizedDescription: "Oops"))
        return OperationResult.success(GeneralSyncSuccess(message: "Brands synced"))
    }
}
