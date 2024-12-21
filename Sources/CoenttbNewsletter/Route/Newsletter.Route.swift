//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 05/09/2024.
//


import Dependencies
import Foundation
import Languages
import URLRouting
import MacroCodableKit

public enum Route: Codable, Hashable, Sendable {
    case subscribe(CoenttbNewsletter.Route.Subscribe)
    case unsubscribe
}

extension CoenttbNewsletter.Route {
    public enum Subscribe: Codable, Hashable, Sendable {
        case request
        case verify(CoenttbNewsletter.Route.Subscribe.Verify)
    }
}

extension CoenttbNewsletter.Route.Subscribe {
    @Codable
    public struct Verify: Hashable, Sendable {
       @CodingKey("token")
        public let token: String
        
       @CodingKey("email")
        public let email: String
        
        public init(
            token: String = "",
            email: String = ""
        ) {
            self.token = token
            self.email = email
        }
    }
}

extension Route {
    public enum Unsubscribe {}
}

extension CoenttbNewsletter.Route {
    public struct Router: ParserPrinter {
        
        public init(){}
        
        public var body: some URLRouting.Router<CoenttbNewsletter.Route> {
            OneOf {
                URLRouting.Route(.case(CoenttbNewsletter.Route.subscribe)) {
                    Path { "subscribe" }
                    OneOf {
                        URLRouting.Route(.case(CoenttbNewsletter.Route.Subscribe.request)) {
                            Path { "request" }
                        }
                        
                        URLRouting.Route(.case(CoenttbNewsletter.Route.Subscribe.verify)) {
                            Path { "email-verification" }
                            Parse(.memberwise(CoenttbNewsletter.Route.Subscribe.Verify.init)) {
                                Query {
                                    Field(CoenttbNewsletter.Route.Subscribe.Verify.CodingKeys.token.rawValue, .string)
                                    Field(CoenttbNewsletter.Route.Subscribe.Verify.CodingKeys.email.rawValue, .string)
                                }
                            }
                        }
                    }
                }
                
                URLRouting.Route(.case(CoenttbNewsletter.Route.unsubscribe)) {
                    Path { String.unsubscribe.description }
                }
            }
        }
    }
}


