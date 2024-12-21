//
//  File.swift
//  coenttb-web
//
//  Subscribed by Coen ten Thije Boonkkamp on 10/09/2024.
//


import Dependencies
import EmailAddress
import Foundation
import Languages
import MemberwiseInit
import URLRouting
import MacroCodableKit
import UrlFormCoding

public enum API: Equatable, Sendable {
    case subscribe(CoenttbNewsletter.API.Subscribe)
    case unsubscribe(CoenttbNewsletter.API.Unsubscribe)
}

extension CoenttbNewsletter.API {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<CoenttbNewsletter.API> {
            OneOf {
                URLRouting.Route(.case(CoenttbNewsletter.API.subscribe)) {
                    Path { "subscribe" }
                    CoenttbNewsletter.API.Subscribe.Router()
                }
                
                URLRouting.Route(.case(CoenttbNewsletter.API.unsubscribe)) {
                    Method.get
                    Path { "unsubscribe" }
                    Body(.form(CoenttbNewsletter.API.Unsubscribe.self, decoder: .default))
                }
            }
        }
    }
}

extension CoenttbNewsletter.API {
    @MemberwiseInit(.public)
    @Codable
    public struct Unsubscribe: Hashable, Sendable {
       @CodingKey("email")
        @Init(default: "")
        public let value: String
    }
}

extension CoenttbNewsletter.API {
    public enum Subscribe: Equatable, Sendable {
        case request(CoenttbNewsletter.API.Subscribe.Request)
        case verify(CoenttbNewsletter.API.Subscribe.Verify)
    }
}

extension CoenttbNewsletter.API.Subscribe {
    @MemberwiseInit(.public)
    @Codable
    public struct Request: Hashable, Sendable {
        @CodingKey("email")
        @Init(default: "")
        public let email: String
    }

    @MemberwiseInit(.public)
    @Codable
    public struct Verify: Hashable, Sendable {
        @CodingKey("token")
        @Init(default: "")
        public let token: String
        
        @CodingKey("email")
        @Init(default: "")
        public let email: String
    }
}

extension CoenttbNewsletter.API.Subscribe {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<CoenttbNewsletter.API.Subscribe> {
            OneOf {
                URLRouting.Route(.case(CoenttbNewsletter.API.Subscribe.request)) {
                    Method.post
                    Path { "request" }
                    Body(.form(CoenttbNewsletter.API.Subscribe.Request.self, decoder: .default))
                }
                URLRouting.Route(.case(CoenttbNewsletter.API.Subscribe.verify)) {
                    Method.post
                    Path { "verify" }
                    Parse(.memberwise(CoenttbNewsletter.API.Subscribe.Verify.init)) {
                        Query {
                            Field(CoenttbNewsletter.API.Subscribe.Verify.CodingKeys.token.rawValue, .string)
                            Field(CoenttbNewsletter.API.Subscribe.Verify.CodingKeys.email.rawValue, .string)
                        }
                    }
                }
            }

        }
    }
}

extension UrlFormDecoder {
    fileprivate static var `default`: UrlFormDecoder {
        let decoder = UrlFormDecoder()
        decoder.parsingStrategy = .bracketsWithIndices
        return decoder
    }
}
