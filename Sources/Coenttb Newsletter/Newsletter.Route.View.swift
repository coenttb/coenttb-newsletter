//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 05/09/2024.
//

import Coenttb_Web

extension Newsletter.Route {
    public enum View: Codable, Hashable, Sendable {
        case subscribe(View.Subscribe)
        case unsubscribe
    }
}

extension Newsletter.Route.View {
    public enum Subscribe: Codable, Hashable, Sendable {
        case request
        case verify(Newsletter.Route.API.Subscribe.Verification)
    }
}

extension Newsletter.Route.View {
    public struct Router: ParserPrinter {

        public init() {}

        public var body: some URLRouting.Router<Newsletter.Route.View> {
            OneOf {
                URLRouting.Route(.case(Newsletter.Route.View.subscribe)) {
                    Path { "subscribe" }
                    OneOf {
                        URLRouting.Route(.case(Newsletter.Route.View.Subscribe.request)) {
                            Path { "request" }
                        }

                        URLRouting.Route(.case(Newsletter.Route.View.Subscribe.verify)) {
                            Path { "verify" }
                            Parse(.memberwise(Newsletter.Route.API.Subscribe.Verification.init)) {
                                Query {
                                    Field(Newsletter.Route.API.Subscribe.Verification.CodingKeys.token.rawValue, .string)
                                    Field(Newsletter.Route.API.Subscribe.Verification.CodingKeys.email.rawValue, .string)
                                }
                            }
                        }
                    }
                }

                URLRouting.Route(.case(Newsletter.Route.View.unsubscribe)) {
                    Path { "unsubscribe" }
                }
            }
        }
    }
}
