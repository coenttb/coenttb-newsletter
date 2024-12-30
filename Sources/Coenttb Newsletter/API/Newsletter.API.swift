//
//  File.swift
//  coenttb-web
//
//  Subscribed by Coen ten Thije Boonkkamp on 10/09/2024.
//


import Coenttb_Web

public enum API: Equatable, Sendable {
    case subscribe(Coenttb_Newsletter.API.Subscribe)
    case unsubscribe(Coenttb_Newsletter.API.Unsubscribe)
}

extension Coenttb_Newsletter.API {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<Coenttb_Newsletter.API> {
            OneOf {
                URLRouting.Route(.case(Coenttb_Newsletter.API.subscribe)) {
                    Path { "subscribe" }
                    Coenttb_Newsletter.API.Subscribe.Router()
                }
                
                URLRouting.Route(.case(Coenttb_Newsletter.API.unsubscribe)) {
                    Method.get
                    Path { "unsubscribe" }
                    Body(.form(Coenttb_Newsletter.API.Unsubscribe.self, decoder: .default))
                }
            }
        }
    }
}

extension Coenttb_Newsletter.API {
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

extension Coenttb_Newsletter.API.Unsubscribe {
    public init(
        email: EmailAddress
    ){
        self.email = email.rawValue
    }
}

extension Coenttb_Newsletter.API {
    public enum Subscribe: Equatable, Sendable {
        case request(Coenttb_Newsletter.API.Subscribe.Request)
        case verify(Coenttb_Newsletter.API.Subscribe.Verify)
    }
}

extension Coenttb_Newsletter.API.Subscribe {
    public struct Request: Codable, Hashable, Sendable {
        public let email: String
        
        public init(email: String = "") {
            self.email = email
        }
        
        public enum CodingKeys: String, CodingKey {
            case email
        }
    }
}

extension Coenttb_Newsletter.API.Subscribe.Request {
    public init(
        email: EmailAddress
    ){
        self.email = email.rawValue
    }
}

extension Coenttb_Newsletter.API.Subscribe {
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

extension Coenttb_Newsletter.API.Subscribe.Verify {
    public init(
        token: String,
        email: EmailAddress
    ){
        self.token = token
        self.email = email.rawValue
    }
}

extension Coenttb_Newsletter.API.Subscribe {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<Coenttb_Newsletter.API.Subscribe> {
            OneOf {
                URLRouting.Route(.case(Coenttb_Newsletter.API.Subscribe.request)) {
                    Method.post
                    Path { "request" }
                    Body(.form(Coenttb_Newsletter.API.Subscribe.Request.self, decoder: .default))
                }
                URLRouting.Route(.case(Coenttb_Newsletter.API.Subscribe.verify)) {
                    Method.post
                    Path { "verify" }
                    Parse(.memberwise(Coenttb_Newsletter.API.Subscribe.Verify.init)) {
                        Query {
                            Field(Coenttb_Newsletter.API.Subscribe.Verify.CodingKeys.token.rawValue, .string)
                            Field(Coenttb_Newsletter.API.Subscribe.Verify.CodingKeys.email.rawValue, .string)
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
