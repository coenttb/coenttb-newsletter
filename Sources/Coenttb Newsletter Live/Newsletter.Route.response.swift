//
//  File.swift
//  coenttb-newsletter
//
//  Created by Coen ten Thije Boonkkamp on 11/03/2025.
//

import Coenttb_Newsletter
import Coenttb_Vapor
import Coenttb_Web

extension Newsletter.Route {
    public static func response(
        newsletter: Newsletter.Route,
        htmlDocument: (any HTML) -> any (HTMLDocumentProtocol & AsyncResponseEncodable)
    ) async throws -> any AsyncResponseEncodable {
        switch newsletter {
        case .api(let api):
            return try await API.response(newsletter: api)
        case .view(let view):
            return try await View.response(newsletter: view, htmlDocument: htmlDocument)
        }
    }
}
