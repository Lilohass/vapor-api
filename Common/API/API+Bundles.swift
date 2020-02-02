import Foundation
import HTTP

protocol BundlesEndpoint: APIEndpoint {
    static var bundles: String { get }
}

extension API {
    enum Bundles<Endpoint: BundlesEndpoint> {
        
        struct Brand: Codable {
            let name: String
        }
        
        struct CreateRequestBody: Codable {
            let brands: [Brand]
        }

        struct CreateRequestContent: Codable {
            let token: String
            let body: CreateRequestBody
        }

        struct SyncResult: Codable {
            let error: Bool
            let reason: String
        }

        struct CreateResponseContent: Codable {
            let brands: SyncResult
        }
        
        case uploadBundle(CreateRequestContent)
    }
}

extension API.Bundles: APIRequest {
    func request() throws -> HTTPRequest {
        switch self {
        case .uploadBundle(let createBundleRequest):
            return try .jsonPost(url: Endpoint.bundles,
                                 body: createBundleRequest.body,
                                 authToken: createBundleRequest.token)
        }
    }
    
    enum Parser: APIResponseParser {
        case uploadBundle(CreateResponseContent)
    }

    func parseObject(data: Data) throws -> Parser {
        switch self {
        case .uploadBundle:
            return Parser.uploadBundle(try JSONEnvelope<CreateResponseContent>.envelope(data))
        }
    }
}
