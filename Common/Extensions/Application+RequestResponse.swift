import Vapor

struct EmptyContent: Content {}
// MARK: - Application Request
extension Application {
    // 1
    func sendRequest<T>(to path: String, method: HTTPMethod, headers: HTTPHeaders = .init(),
                        body: T? = nil) throws -> Response where T: Content {
      let responder = try self.make(Responder.self)
      // 2
      let request = HTTPRequest(method: method, url: URL(string: path)!,
                                headers: headers)
      let wrappedRequest = Request(http: request, using: self)
      // 3
      if let body = body {
        try wrappedRequest.content.encode(body)
      }
      // 4
      return try responder.respond(to: wrappedRequest).wait()
    }

    // 5
    func sendRequest(to path: String, method: HTTPMethod,
                     headers: HTTPHeaders = .init()) throws -> Response {
      // 6
      let emptyContent: EmptyContent? = nil
      // 7
      return try sendRequest(to: path, method: method, headers: headers,
                             body: emptyContent)
    }

    // 8
    func sendRequest<T>(to path: String, method: HTTPMethod, headers: HTTPHeaders,
                        data: T) throws where T: Content {
      // 9
      _ = try self.sendRequest(to: path, method: method, headers: headers,
                               body: data)
    }
}

// MARK: - Application Response
extension Application {
    
    func getResponse(request: HTTPRequest) throws -> HTTPResponse {
        let request = Request(http: request, using: self)
        let responder = try make(Responder.self)
        let response = try responder.respond(to: request).wait()
        return response.http
    }
    
    // 1
    func getResponse<C,T>(to path: String, method: HTTPMethod = .GET,
                          headers: HTTPHeaders = .init(), data: C? = nil,
                          decodeTo type: T.Type) throws -> T where C: Content, T: Decodable {
      // 2
      let response = try self.sendRequest(to: path, method: method,
                                          headers: headers, body: data)
      // 3
      return try response.content.decode(type).wait()
    }

    // 4
    func getResponse<T>(to path: String, method: HTTPMethod = .GET,
                        headers: HTTPHeaders = .init(),
                        decodeTo type: T.Type) throws -> T where T: Decodable {
      // 5
      let emptyContent: EmptyContent? = nil
      // 6
      return try self.getResponse(to: path, method: method, headers: headers,
                                  data: emptyContent, decodeTo: type)
    }
}

