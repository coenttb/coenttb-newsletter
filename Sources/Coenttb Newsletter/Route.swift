//
//  File.swift
//  coenttb-newsletter
//
//  Created by Coen ten Thije Boonkkamp on 11/03/2025.
//

import Coenttb_Web

public enum Route: Equatable, Sendable {
    case api(API)
    case view(View)
}

extension Route {
    public struct Router: ParserPrinter {
        
        public init(){}
        
        public var body: some URLRouting.Router<Route> {
            OneOf {
                URLRouting.Route(.case(Route.api)) {
                    API.Router()
                }
                URLRouting.Route(.case(Route.view)) {
                    View.Router()
                }
            }
        }
    }
}
