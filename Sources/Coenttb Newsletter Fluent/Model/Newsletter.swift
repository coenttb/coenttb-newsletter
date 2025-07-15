//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 05/09/2024.
//

import Coenttb_Newsletter
import Coenttb_Newsletter_Live
import Coenttb_Web_Utils
import Dependencies

@preconcurrency import Fluent
@preconcurrency import Vapor

public final class Newsletter: Model, @unchecked Sendable {
    public static let schema = "newsletter_subscriptions"

    @ID(key: .id)
    public var id: UUID?

    @Field(key: Newsletter.FieldKeys.email)
    public var email: String

    @Field(key: Newsletter.FieldKeys.emailVerificationStatus)
    public var emailVerificationStatus: EmailVerificationStatus

    @Timestamp(key: Newsletter.FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    public var updatedAt: Date?

    @Field(key: FieldKeys.lastEmailMessageId)
    var lastEmailMessageId: String?

    public init() { }

    public init(
        id: UUID? = nil,
        email: String,
        emailVerificationStatus: EmailVerificationStatus = .unverified,
        lastEmailMessageId: String? = nil
    ) throws {
        self.id = id
        self.lastEmailMessageId = lastEmailMessageId
        do {
            if try Bool.isValidEmail(email) {
                self.email = email
                self.emailVerificationStatus = emailVerificationStatus
            } else {
                throw EmailValidationError.invalidEmailFormat
            }
        } catch {
            throw error
        }
    }

    enum FieldKeys {
        public static let email: FieldKey = "email"
        public static let emailVerificationStatus: FieldKey = "email_verification_status"
        public static let createdAt: FieldKey = "created_at"
        public static let updatedAt: FieldKey = "updated_at"
        public static let lastEmailMessageId: FieldKey = "last_email_message_id"
    }
}

extension Newsletter {
    public enum EmailVerificationStatus: String, Codable, Sendable {
        case unverified
        case pending
        case verified
        case failed
    }
}

extension Newsletter {
    public func generateToken(type: Newsletter.Token.TokenType, validUntil: Date? = nil) throws -> Newsletter.Token {
        try .init(
            newsletter: self,
            type: type,
            validUntil: validUntil
        )
    }
}

extension Newsletter {
    public func canGenerateToken(on db: Database) async throws -> Bool {
        guard let id = self.id else { return false }

        @Dependency(\.date) var date
        let recentTokens = try await Newsletter.Token.query(on: db)
            .filter(\.$newsletter.$id == id)
            .filter(\.$createdAt >= date().addingTimeInterval(-Newsletter.Token.generationWindow))
            .count()

        return recentTokens < Newsletter.Token.generationLimit
    }
}

extension Newsletter {
    public enum Migration {
        public struct Create: AsyncMigration {

            public var name: String = "Coenttb_Newsletter.CreateNewsletter"

            public init() {}

            public func prepare(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .id()
                    .field(Newsletter.FieldKeys.email, .string, .required)
                    .field(Newsletter.FieldKeys.createdAt, .datetime)
                    .unique(on: Newsletter.FieldKeys.email)
                    .create()
            }

            public func revert(on database: Database) async throws {
                try await database.schema(Newsletter.schema).delete()
            }
        }

        public struct STEP_1_AddUpdatedAt: AsyncMigration {

            public var name: String = "Coenttb_Newsletter.Newsletter.Migration.STEP_1_AddUpdatedAt"

            public init() {}

            public func prepare(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .field(Newsletter.FieldKeys.updatedAt, .datetime, .required)
                    .update()

                try await Newsletter.query(on: database)
                    .set(\.$updatedAt, to: .now)
                    .update()
            }

            public func revert(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .deleteField(Newsletter.FieldKeys.updatedAt)
                    .update()
            }
        }

        public struct STEP_2_AddEmailVerification: AsyncMigration {

            public var name: String = "Coenttb_Newsletter.Newsletter.Migration.STEP_2_AddEmailVerification"

            public init() {}

            public func prepare(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .field(FieldKeys.emailVerificationStatus, .string, .required)
                    .update()

                try await Newsletter.query(on: database)
                    .set(\.$emailVerificationStatus, to: .unverified)
                    .update()
            }

            public func revert(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .deleteField(FieldKeys.emailVerificationStatus)
                    .update()
            }
        }

        public struct STEP_3_AddLastEmailMessageId: AsyncMigration {

            public var name: String = "Coenttb_Newsletter.Newsletter.Migration.STEP_2_AddLastEmailMessageId"

            public init() {}

            public func prepare(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .field(FieldKeys.lastEmailMessageId, .string)
                    .update()
            }

            public func revert(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .deleteField(FieldKeys.lastEmailMessageId)
                    .update()
            }
        }
    }
}
