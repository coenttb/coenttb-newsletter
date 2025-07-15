//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Coenttb_Database
import Coenttb_Newsletter
import Coenttb_Vapor
import Coenttb_Web
import RateLimiter

extension Newsletter.Route.API {
    public static func response(
        newsletter: Newsletter.Route.API
    ) async throws -> any AsyncResponseEncodable {
        @Dependency(\.logger) var logger
        @Dependency(\.newsletter.cookieId) var cookieId
        @Dependency(\.newsletter.client) var client
        @Dependency(\.newsletter.emailLimiter) var emailLimiter
        @Dependency(\.newsletter.ipLimiter) var ipLimiter

        switch newsletter {
        case .subscribe(let subscribe):
            switch subscribe {
            case .request(let request):
                let email = request.email

                logger.info("Received subscription request for email: \(email)")

                @Dependency(\.request) var request

                let ipAddress = request?.realIP ?? "unknown"

                do {

                    // Check both email and IP limits
                    let emailResult = await emailLimiter.checkLimit(.email(email))
                    let ipResult = await ipLimiter.checkLimit(.ip(ipAddress))

                    logger.info("Rate limit check results - Email attempts: \(emailResult.currentAttempts), IP attempts: \(ipResult.currentAttempts)")

                    if !emailResult.isAllowed {
                        throw Abort(.tooManyRequests, reason: "Too many subscription attempts from this email. Please try again later.")
                    }

                    if !emailResult.isAllowed || !ipResult.isAllowed {
                        // Get the most restrictive rate limit details
                        let mostRestrictive = !emailResult.isAllowed ? emailResult : ipResult
                        let source = !emailResult.isAllowed ? "email" : "IP address"

                        let response = Response(
                            status: .tooManyRequests,
                            body: .init(string: "Too many subscription attempts from this \(source). Please try again later.")
                        )

                        response.headers.add(
                            name: .xRateLimitLimit,
                            value: "\(mostRestrictive.currentAttempts + mostRestrictive.remainingAttempts)"
                        )

                        response.headers.add(
                            name: .xRateLimitRemaining,
                            value: "\(mostRestrictive.remainingAttempts)"
                        )

                        response.headers.add(
                            name: .xRateLimitReset,
                            value: "\(mostRestrictive.nextAllowedAttempt?.timeIntervalSince1970 ?? 0)"
                        )

                        response.headers.add(
                            name: .xRateLimitSource,
                            value: source
                        )

                        response.headers.add(
                            name: .xEmailRateLimitRemaining,
                            value: "\(emailResult.remainingAttempts)"
                        )

                        response.headers.add(
                            name: .xIPRateLimitRemaining,
                            value: "\(ipResult.remainingAttempts)"
                        )

                        return response
                    }

                    try await client.subscribe.request(.init(email))

                    await emailLimiter.recordSuccess(.email(email))
                    await ipLimiter.recordSuccess(.ip(ipAddress))

                    let response = Response.json(success: true, message: "Successfully subscribed")

                    response.headers.add(
                        name: .xRateLimitLimit,
                        value: "\(emailResult.currentAttempts + emailResult.remainingAttempts)"
                    )

                    response.headers.add(
                        name: .xRateLimitRemaining,
                        value: "\(min(emailResult.remainingAttempts, ipResult.remainingAttempts))"
                    )

                    response.headers.add(
                        name: .xRateLimitReset,
                        value: "\(min(emailResult.nextAllowedAttempt?.timeIntervalSince1970 ?? 0, ipResult.nextAllowedAttempt?.timeIntervalSince1970 ?? 0))"
                    )

                    response.headers.add(
                        name: .xEmailRateLimitRemaining,
                        value: "\(emailResult.remainingAttempts)"
                    )

                    response.headers.add(
                        name: .xIPRateLimitRemaining,
                        value: "\(ipResult.remainingAttempts)"
                    )

                    @Dependency(\.envVars.appEnv) var appEnv

                    response.cookies[cookieId()] = HTTPCookies.Value(
                        string: "true",
                        expires: .distantFuture,
                        maxAge: nil,
                        isSecure: appEnv == .production ? true : false,
                        isHTTPOnly: false,
                        sameSite: .strict
                    )

                    return response
                }
//                catch let error as ValidationError {
//                    switch error {
//                    case .tooManyAttempts:
//                        await emailLimiter.recordFailure(.email(email))
//                        await ipLimiter.recordFailure(.ip(ipAddress))
//                        throw Abort(.tooManyRequests, reason: "Too many subscription attempts. Please try again later.")
//                    default:
//                        throw error
//                    }
//                }
                catch {
                    await emailLimiter.recordFailure(.email(email))
                    await ipLimiter.recordFailure(.ip(ipAddress))
                    logger.error("Subscription failed: \(error)")
                    throw Abort(.internalServerError, reason: "Failed to process subscription. Please try again later.")
                }

            case .verify(let verify):
                logger.info("Processing verification request for email: \(verify.email) with token: \(verify.token)")

                do {

                    @Dependency(\.request) var request

                    let ipAddress = request?.realIP ?? "unknown"

                    // Check both email and IP limits for verification
                    let emailResult = await emailLimiter.checkLimit(.email(verify.email))
                    let ipResult = await ipLimiter.checkLimit(.ip(ipAddress))

                    if !emailResult.isAllowed || !ipResult.isAllowed {
                        throw Abort(.tooManyRequests, reason: "Too many verification attempts. Please try again later.")
                    }

                    try await client.subscribe.verify(verify.token, .init(verify.email))

                    // Record success
                    await emailLimiter.recordSuccess(.email(verify.email))
                    await ipLimiter.recordSuccess(.ip(ipAddress))

                    @Dependency(\.envVars.appEnv) var appEnv

                    let cookieValue = HTTPCookies.Value(
                        string: "true",
                        expires: .distantFuture,
                        maxAge: nil,
                        isSecure: appEnv == .production ? true : false,
                        isHTTPOnly: false,
                        sameSite: .strict
                    )

                    let response = Response.json(success: true, message: "Email successfully verified")
                    response.cookies[cookieId()] = cookieValue
                    return response

                }
//                catch let error as ValidationError {
//                    switch error {
//                    case .invalidToken:
//                        throw Abort(.badRequest, reason: "Invalid or expired verification token")
//                    case .invalidInput:
//                        throw Abort(.badRequest, reason: "Invalid verification data provided")
//                    case .invalidVerificationStatus:
//                        throw Abort(.badRequest, reason: "Invalid verification status")
//                    case .tooManyAttempts:
//                        throw Abort(.tooManyRequests, reason: "Too many verification attempts")
//                    }
//                }
                catch {
                    logger.error("Verification failed: \(error)")
                    throw Abort(.internalServerError, reason: "Verification failed. Please try again later.")
                }
            }

        case .unsubscribe(let emailAddress):
            logger.info("Received unsubscription request for email: \(emailAddress.email)")
            try await client.unsubscribe(.init(emailAddress.email))

            let response = Response.json(success: true)
            response.cookies[cookieId()] = nil
            return response

        }
    }
}
