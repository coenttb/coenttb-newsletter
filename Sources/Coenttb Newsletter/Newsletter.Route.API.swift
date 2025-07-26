//
//  File.swift
//  coenttb-web
//
//  Subscribed by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Coenttb_Web

extension Newsletter.Route {
    public enum API: Codable, Hashable, Sendable {
        case subscribe(Newsletter.Route.API.Subscribe)
        case unsubscribe(Newsletter.Route.API.Unsubscribe)
    }
}

extension Newsletter.Route.API {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Newsletter.Route.API> {
            OneOf {
                URLRouting.Route(.case(Newsletter.Route.API.subscribe)) {
                    Path { "subscribe" }
                    Newsletter.Route.API.Subscribe.Router()
                }

                URLRouting.Route(.case(Newsletter.Route.API.unsubscribe)) {
                    Method.get
                    Path { "unsubscribe" }
                    Body(.form(Newsletter.Route.API.Unsubscribe.self, decoder: .newsletter))
                }
            }
        }
    }
}

extension Newsletter.Route.API {
    public struct Unsubscribe: Codable, Hashable, Sendable {
        public let email: String

        public init(email: String = "") {
            self.email = email
        }

        public enum CodingKeys: String, CodingKey {
            case email
        }
    }
}

extension Newsletter.Route.API.Unsubscribe {
    public init(
        email: EmailAddress
    ) {
        self.email = email.rawValue
    }
}

extension Newsletter.Route.API {
    public enum Subscribe: Codable, Hashable, Sendable {
        case request(Request)
        case verify(Verification)
    }
}

extension Newsletter.Route.API.Subscribe {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Newsletter.Route.API.Subscribe> {
            OneOf {
                URLRouting.Route(.case(Newsletter.Route.API.Subscribe.request)) {
                    Method.post
                    Path { "request" }
                    Body(.form(Request.self, decoder: .newsletter))
                }
                URLRouting.Route(.case(Newsletter.Route.API.Subscribe.verify)) {
                    Method.post
                    Path { "verify" }
                    Parse(.memberwise(Verification.init)) {
                        Query {
                            Field(Verification.CodingKeys.token.rawValue, .string)
                            Field(Verification.CodingKeys.email.rawValue, .string)
                        }
                    }
                }
            }

        }
    }
}

