//
//  File.swift
//  coenttb-newsletter
//
//  Created by Coen ten Thije Boonkkamp on 11/03/2025.
//

import Coenttb_Web

extension Newsletter {
    public enum Route: Codable, Hashable, Sendable {
        case api(Newsletter.Route.API)
        case view(Newsletter.Route.View)
    }
}

extension Newsletter.Route {
    public struct Router: ParserPrinter {

        public init() {}

        public var body: some URLRouting.Router<Newsletter.Route> {
            OneOf {
                URLRouting.Route(.case(Newsletter.Route.api)) {
                    Newsletter.Route.API.Router()
                }
                URLRouting.Route(.case(Newsletter.Route.view)) {
                    Newsletter.Route.View.Router()
                }
            }
        }
    }
}
