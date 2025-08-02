//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 05/09/2024.
//

import Coenttb_Newsletter
import Coenttb_Newsletter_Live
import EmailAddress
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
            if (try? EmailAddress(email)) != nil {
                self.email = email
                self.emailVerificationStatus = emailVerificationStatus
            } else {
                throw EmailAddress.EmailAddressError.invalidFormat(description: "Invalid email-format for: \(email)")
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
        package struct Create: AsyncMigration {

            package var name: String = "Coenttb_Newsletter.CreateNewsletter"

            package init() {}

            package func prepare(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .id()
                    .field("email", .string, .required)
                    .field("created_at", .datetime)
                    .unique(on: "email")
                    .create()
            }

            package func revert(on database: Database) async throws {
                try await database.schema(Newsletter.schema).delete()
            }
        }

        package struct STEP_1_AddUpdatedAt: AsyncMigration {

            package var name: String = "Coenttb_Newsletter.Newsletter.Migration.STEP_1_AddUpdatedAt"

            package init() {}

            package func prepare(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .field("updated_at", .datetime, .required)
                    .update()

                try await Newsletter.query(on: database)
                    .set(\.$updatedAt, to: .now)
                    .update()
            }

            package func revert(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .deleteField("updated_at")
                    .update()
            }
        }

        package struct STEP_2_AddEmailVerification: AsyncMigration {

            package var name: String = "Coenttb_Newsletter.Newsletter.Migration.STEP_2_AddEmailVerification"

            package init() {}

            package func prepare(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .field("email_verification_status", .string, .required)
                    .update()

                try await Newsletter.query(on: database)
                    .set(\.$emailVerificationStatus, to: .unverified)
                    .update()
            }

            package func revert(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .deleteField("email_verification_status")
                    .update()
            }
        }

        package struct STEP_3_AddLastEmailMessageId: AsyncMigration {

            package var name: String = "Coenttb_Newsletter.Newsletter.Migration.STEP_2_AddLastEmailMessageId"

            package init() {}

            package func prepare(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .field("last_email_message_id", .string)
                    .update()
            }

            package func revert(on database: Database) async throws {
                try await database.schema(Newsletter.schema)
                    .deleteField("last_email_message_id")
                    .update()
            }
        }
    }
}

extension Coenttb_Newsletter_Fluent.Newsletter.Migration {
    public static var allCases: [any Fluent.Migration] {
        [
            {
                var migration = Newsletter.Migration.Create()
                migration.name = "Coenttb_Newsletter.Newsletter.Migration.Create"
                return migration
            }(),
            {
                var migration = Coenttb_Newsletter_Fluent.Newsletter.Token.Migration.Create()
                migration.name = "Coenttb_Newsletter.Newsletter.Token.Migration.Create"
                return migration
            }(),
            {
                var migration = Coenttb_Newsletter_Fluent.Newsletter.Migration.STEP_1_AddUpdatedAt()
                migration.name = "Coenttb_Newsletter.Newsletter.Migration.STEP_1_AddUpdatedAt"
                return migration
            }(),
            {
                var migration = Coenttb_Newsletter_Fluent.Newsletter.Migration.STEP_2_AddEmailVerification()
                migration.name = "Coenttb_Newsletter.Newsletter.Migration.STEP_2_AddEmailVerification"
                return migration
            }(),
            {
                var migration = Coenttb_Newsletter_Fluent.Newsletter.Migration.STEP_3_AddLastEmailMessageId()
                migration.name = "Coenttb_Newsletter.Newsletter.Migration.STEP_3_AddLastEmailMessageId"
                return migration
            }()
        ]
    }
}
