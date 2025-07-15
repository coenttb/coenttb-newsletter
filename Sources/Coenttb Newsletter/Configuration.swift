//
//  File.swift
//  coenttb-newsletter
//
//  Created by Coen ten Thije Boonkkamp on 11/03/2025.
//

import Foundation
import RateLimiter
import Dependencies
import DependenciesMacros

@DependencyClient
@dynamicMemberLookup
public struct Newsletter: Sendable {
    public var client: Client
    public var configuration: Newsletter.Configuration
    
    public init(
        client: Newsletter.Client,
        configuration: Newsletter.Configuration
    ) {
        self.client = client
        self.configuration = configuration
    }
    
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Client, T>) -> T {
        self.client[keyPath: keyPath]
    }
    
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Newsletter.Configuration, T>) -> T {
        self.configuration[keyPath: keyPath]
    }
}

extension Newsletter {
    public struct Configuration: Sendable {
        public var cookieId: @Sendable () -> String
        public var saveToLocalstorage: Bool
        public var subscribeAction: @Sendable () -> URL
        public var subscribeCaption: @Sendable () -> String
        public var subscribeFormId: @Sendable () -> String
        public var subscribeOverlayId: @Sendable () -> String
        public var unsubscribeAction: @Sendable () -> URL
        public var unsubscribeFormId: @Sendable () -> String
        public var verificationAction: @Sendable (_ verification: Verification) -> URL
        public var verificationRedirectURL: @Sendable () -> URL
        public var verificationTimeout: @Sendable () -> TimeInterval
        public var localStorageKey: @Sendable () -> String
        public var emailLimiter: RateLimiter<RateLimitKey>
        public var ipLimiter: RateLimiter<RateLimitKey>
        
        public init(
            saveToLocalstorage: Bool,
            localStorageKey: @Sendable @escaping () -> String = { "newsletter-storage-key" },
            cookieId: @Sendable @escaping () -> String,
            subscribeAction: @Sendable @escaping () -> URL,
            subscribeCaption: @Sendable @escaping () -> String,
            subscribeFormId: @Sendable @escaping () -> String,
            subscribeOverlayId: @Sendable @escaping () -> String,
            unsubscribeAction: @Sendable @escaping () -> URL,
            unsubscribeFormId: @Sendable @escaping () -> String,
            verificationAction: @Sendable @escaping (Verification) -> URL,
            verificationRedirectURL: @Sendable @escaping () -> URL,
            verificationTimeout: @Sendable @escaping () -> TimeInterval = { 24 * 60 * 60 },
            emailLimiter: RateLimiter<RateLimitKey> = .emailLimiter,
            ipLimiter: RateLimiter<RateLimitKey> = .ipLimiter
        ) {
            self.cookieId = cookieId
            self.saveToLocalstorage = saveToLocalstorage
            self.subscribeAction = subscribeAction
            self.subscribeCaption = subscribeCaption
            self.subscribeFormId = subscribeFormId
            self.subscribeOverlayId = subscribeOverlayId
            self.unsubscribeAction = unsubscribeAction
            self.unsubscribeFormId = unsubscribeFormId
            self.verificationAction = verificationAction
            self.verificationRedirectURL = verificationRedirectURL
            self.verificationTimeout = verificationTimeout
            self.localStorageKey = localStorageKey
            self.emailLimiter = emailLimiter
            self.ipLimiter = ipLimiter
        }
    }
}

extension Newsletter {
    public enum RateLimitKey: Hashable, Sendable {
        case email(String)
        case ip(String)
    }
}

extension RateLimiter<Newsletter.RateLimitKey> {
    public static let emailLimiter: RateLimiter<Newsletter.RateLimitKey> = .init(
        windows: [
            .minutes(5, maxAttempts: 3),
            .hours(24, maxAttempts: 10)
        ],
        backoffMultiplier: 2.0
    )
}

extension RateLimiter<Newsletter.RateLimitKey> {
    public static let ipLimiter: RateLimiter<Newsletter.RateLimitKey> = .init(
        windows: [
            .minutes(5, maxAttempts: 5),
            .hours(24, maxAttempts: 20)
        ],
        backoffMultiplier: 2.0
    )
}

private enum RateLimitKey: Hashable, Sendable {
    case email(String)
    case ip(String)
}

extension Newsletter: TestDependencyKey {
    public static let testValue: Newsletter = {
        fatalError()
    }()
}

extension DependencyValues {
    public var newsletter: Newsletter {
        get { self[Newsletter.self] }
        set { self[Newsletter.self] = newValue }
    }
}
