//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2024.
//

import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor
import Coenttb_Newsletter
import Coenttb_Newsletter_Live

extension Newsletter {
    public final class Token: Model, @unchecked Sendable {
        public static let schema = "newsletter_verification_tokens"
        
        @ID(key: .id)
        public var id: UUID?
        
        @Field(key: FieldKeys.value)
        public var value: String
        
        @Field(key: FieldKeys.type)
        public var type: TokenType
        
        @Field(key: FieldKeys.validUntil)
        public var validUntil: Date
        
        @Parent(key: FieldKeys.newsletterId)
        public var newsletter: Newsletter
        
        @Timestamp(key: FieldKeys.createdAt, on: .create)
        public var createdAt: Date?
        
        public init() { }
        
        public init(
            newsletter: Newsletter,
            type: TokenType,
            validUntil: Date? = nil
        ) throws {
            self.value = [UInt8].random(count: 32).base64
            self.type = type
            self.validUntil = validUntil ?? Date().addingTimeInterval(24 * 60 * 60)
            self.$newsletter.id = try newsletter.requireID()
        }
        
        public var isValid: Bool {
            validUntil > Date()
        }
        
        enum FieldKeys {
            static let value: FieldKey = "value"
            static let type: FieldKey = "type"
            static let validUntil: FieldKey = "valid_until"
            static let newsletterId: FieldKey = "newsletter_id"
            static let createdAt: FieldKey = "created_at"
        }
        
        public struct TokenType: RawRepresentable, Codable, Equatable, Sendable {
            public let rawValue: String
            
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
            
            public static let emailVerification: Self = .init(rawValue: "email_verification")
        }
    }
}

extension Newsletter.Token {
    static let generationLimit = 5
    static let generationWindow: TimeInterval = 3600 // 1 hour
}


extension Newsletter.Token {
    public enum Migration {
        public struct Create: AsyncMigration {
            
            public var name: String = "Coenttb_Newsletter.Newsletter.Token.Migration.Create"
            
            public init() {}
            
            public func prepare(on database: Database) async throws {
                try await database.schema(Newsletter.Token.schema)
                    .id()
                    .field(FieldKeys.value, .string, .required)
                    .field(FieldKeys.type, .string, .required)
                    .field(FieldKeys.validUntil, .datetime, .required)
                    .field(FieldKeys.newsletterId, .uuid, .required, .references(Newsletter.schema, "id", onDelete: .cascade))
                    .field(FieldKeys.createdAt, .datetime)
                    .unique(on: FieldKeys.value)
                    .create()
            }
            
            public func revert(on database: Database) async throws {
                try await database.schema(Newsletter.Token.schema).delete()
            }
        }
    }
}
