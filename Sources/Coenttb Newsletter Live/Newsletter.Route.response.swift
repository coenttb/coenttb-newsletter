//
//  File.swift
//  coenttb-newsletter
//
//  Created by Coen ten Thije Boonkkamp on 11/03/2025.
//

import Coenttb_Newsletter
import Coenttb_Web
import Coenttb_Vapor

extension Coenttb_Newsletter.Route {
    public static func response(
        newsletter: Coenttb_Newsletter.Route,
        htmlDocument: (any HTML) -> any (HTMLDocument & AsyncResponseEncodable)
    ) async throws -> any AsyncResponseEncodable {
        switch newsletter {
        case .api(let api):
            return try await API.response(newsletter: api)
        case .view(let view):
            return try await View.response(newsletter: view, htmlDocument: htmlDocument)
        }
    }
}
