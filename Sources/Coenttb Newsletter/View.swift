//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 05/09/2024.
//


import Coenttb_Web

public enum View: Codable, Hashable, Sendable {
    case subscribe(View.Subscribe)
    case unsubscribe
}

extension Coenttb_Newsletter.View {
    public enum Subscribe: Codable, Hashable, Sendable {
        case request
        case verify(Verification)
    }
}

extension Coenttb_Newsletter.View {
    public struct Router: ParserPrinter {
        
        public init(){}
        
        public var body: some URLRouting.Router<Coenttb_Newsletter.View> {
            OneOf {
                URLRouting.Route(.case(Coenttb_Newsletter.View.subscribe)) {
                    Path { "subscribe" }
                    OneOf {
                        URLRouting.Route(.case(Coenttb_Newsletter.View.Subscribe.request)) {
                            Path { "request" }
                        }
                        
                        URLRouting.Route(.case(Coenttb_Newsletter.View.Subscribe.verify)) {
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
                
                URLRouting.Route(.case(Coenttb_Newsletter.View.unsubscribe)) {
                    Path { "unsubscribe" }
                }
            }
        }
    }
}


