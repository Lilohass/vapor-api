import Foundation

typealias SyncResult<Success: SyncSuccess, Failure: SyncError> = Result<Success, Failure>
typealias GeneralSyncResult = SyncResult<GeneralSyncSuccess, GeneralSyncError>

protocol SyncUseCase {
    typealias OperationResult = GeneralSyncResult
    associatedtype Object
    func sync(_ object: Object) -> OperationResult
}

protocol SyncError: Error { }
protocol SyncSuccess {
    var message: String { get }
}

extension Result where Failure: SyncError, Success: SyncSuccess {
    var content: UploadBundleItemResponseContent {
        switch self {
        case .success(let success):
            return UploadBundleItemResponseContent(error: false, reason: success.message)
        case .failure(let syncError):
            return UploadBundleItemResponseContent(error: true, reason: syncError.localizedDescription)
        }
    }
}
struct GeneralSyncError: SyncError {
    let localizedDescription: String
}
struct GeneralSyncSuccess: SyncSuccess {
    let message: String
}
