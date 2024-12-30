//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 05/09/2024.
//


import Coenttb_Web

public enum Route: Codable, Hashable, Sendable {
    case subscribe(Coenttb_Newsletter.Route.Subscribe)
    case unsubscribe
}

extension Coenttb_Newsletter.Route {
    public enum Subscribe: Codable, Hashable, Sendable {
        case request
        case verify(Coenttb_Newsletter.Route.Subscribe.Verify)
    }
}

extension Coenttb_Newsletter.Route.Subscribe {
    public struct Verify: Codable, Hashable, Sendable {
        public let token: String
        public let email: String
        
        public init(
            token: String = "",
            email: String = ""
        ) {
            self.token = token
            self.email = email
        }
        
        public enum CodingKeys: String, CodingKey {
            case token
            case email
        }
    }
}

extension Route {
    public enum Unsubscribe {}
}

extension Coenttb_Newsletter.Route {
    public struct Router: ParserPrinter {
        
        public init(){}
        
        public var body: some URLRouting.Router<Coenttb_Newsletter.Route> {
            OneOf {
                URLRouting.Route(.case(Coenttb_Newsletter.Route.subscribe)) {
                    Path { "subscribe" }
                    OneOf {
                        URLRouting.Route(.case(Coenttb_Newsletter.Route.Subscribe.request)) {
                            Path { "request" }
                        }
                        
                        URLRouting.Route(.case(Coenttb_Newsletter.Route.Subscribe.verify)) {
                            Path { "email-verification" }
                            Parse(.memberwise(Coenttb_Newsletter.Route.Subscribe.Verify.init)) {
                                Query {
                                    Field(Coenttb_Newsletter.Route.Subscribe.Verify.CodingKeys.token.rawValue, .string)
                                    Field(Coenttb_Newsletter.Route.Subscribe.Verify.CodingKeys.email.rawValue, .string)
                                }
                            }
                        }
                    }
                }
                
                URLRouting.Route(.case(Coenttb_Newsletter.Route.unsubscribe)) {
                    Path { String.unsubscribe.description }
                }
            }
        }
    }
}


