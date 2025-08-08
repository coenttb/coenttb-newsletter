//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Database
import Coenttb_Fluent
import Coenttb_Newsletter
import Coenttb_Newsletter_Live
import Coenttb_Vapor
import Coenttb_Web
import Mailgun

extension Coenttb_Newsletter.Newsletter.Client {
    public static func live(
        sendVerificationEmail: @escaping @Sendable (_ email: EmailAddress, _ token: String) async throws -> Mailgun.Messages.Send.Response,
        onSuccessfullyVerified: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        onUnsubscribed: @escaping @Sendable (_ email: EmailAddress) async throws -> Void
    ) -> Self {
        @Dependency(\.database) var database
        @Dependency(\.logger) var logger
        @Dependency(\.newsletter.verificationTimeout) var verificationTimeout

        return .init(
            subscribe: .init(
                request: { emailAddress in
                    do {
                        try await database.transaction { database in
                            // Check if subscription already exists and handle verification state
                            if let existingSubscription = try await Newsletter.query(on: database)
                                .filter(\.$email == emailAddress.rawValue)
                                .first() {

                                switch existingSubscription.emailVerificationStatus {
                                case .verified:
                                    logger.info("Email already verified: \(emailAddress.rawValue)")
                                    return
                                case .pending:
                                    // Delete old pending subscription to allow retry
                                    try await existingSubscription.delete(on: database)
                                case .failed, .unverified:
                                    // Delete failed/unverified to allow retry
                                    try await existingSubscription.delete(on: database)
                                }
                            }

                            // Create new subscription
                            let subscription = try Newsletter(
                                email: emailAddress.rawValue,
                                emailVerificationStatus: .pending
                            )
                            try await subscription.save(on: database)

                            // Check token generation limit
                            guard try await subscription.canGenerateToken(on: database)
                            else { throw ValidationError.tooManyAttempts("Token generation limit exceeded") }

                            // Generate and save token
                            @Dependency(\.date) var date
                            let verificationToken = try subscription.generateToken(
                                type: .emailVerification,
                                validUntil: date().addingTimeInterval(verificationTimeout())
                            )
                            try await verificationToken.save(on: database)

                            let response = try await sendVerificationEmail(emailAddress, verificationToken.value)

                            if response.message.contains("Queued") {
                                logger.info("Verification email queued successfully: \(response.id)")

                                subscription.lastEmailMessageId = response.id
                                try await subscription.save(on: database)
                            } else {
                                logger.error("Unexpected response from email service: \(response.message)")

                                subscription.emailVerificationStatus = .failed
                                try await subscription.save(on: database)

                                try await verificationToken.delete(on: database)
                            }
                        }
                    } catch let error as DatabaseError where error.isConstraintFailure {
                        logger.warning("Duplicate subscription attempt for: \(emailAddress.rawValue)")
                        return
                    } catch {
                        logger.error("Error in newsletter subscription: \(error)")
                        throw error
                    }
                },
                verify: { token, email in
                    do {
                        try await database.transaction { database in
                            // Find token with newsletter
                            guard let verificationToken = try await Newsletter.Token.query(on: database)
                                .filter(\.$value == token)
                                .filter(\.$type == .emailVerification)
                                .with(\.$newsletter)
                                .first() else {
                                throw ValidationError.invalidToken
                            }

                            // Validate token
                            @Dependency(\.date) var date
                            guard verificationToken.validUntil > date() else {
                                try await verificationToken.delete(on: database)
                                throw ValidationError.invalidToken
                            }

                            guard verificationToken.newsletter.email == email.rawValue else {
                                throw ValidationError.invalidInput("Email mismatch")
                            }

                            guard verificationToken.newsletter.emailVerificationStatus == .pending else {
                                throw ValidationError.invalidVerificationStatus("Invalid verification status")
                            }

                            // Update verification status
                            verificationToken.newsletter.emailVerificationStatus = .verified
                            try await verificationToken.newsletter.save(on: database)
                            try await verificationToken.delete(on: database)

                            logger.notice("Newsletter subscription verified for: \(email)")
                        }
                        @Dependency(\.fireAndForget) var fireAndForget
                        await fireAndForget {
                            try await onSuccessfullyVerified(email)
                        }
                    } catch {
                        logger.error("Newsletter verification failed: \(error)")
                        throw error
                    }
                }
            ),
            unsubscribe: { emailAddress in
                do {
                    try await database.transaction { database in
                        try await Newsletter.query(on: database)
                            .filter(\.$email == emailAddress.rawValue)
                            .delete()

                        logger.notice("Newsletter unsubscribed for: \(emailAddress.rawValue)")

                        try await onUnsubscribed(emailAddress)
                    }
                } catch {
                    logger.error("Unsubscribe failed for \(emailAddress.rawValue): \(error)")
                    throw error
                }
            }
        )
    }
}

public enum ValidationError: Swift.Error {
    case invalidInput(String)
    case invalidToken
    case invalidVerificationStatus(String)
    case tooManyAttempts(String)
}
