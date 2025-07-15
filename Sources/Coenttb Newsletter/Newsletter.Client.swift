//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2024.
//

import Coenttb_Web
import DependenciesMacros

extension Newsletter {
    @DependencyClient
    public struct Client: @unchecked Sendable {

        public var subscribe: Newsletter.Client.Subscribe

        @DependencyEndpoint
        public var unsubscribe: (EmailAddress) async throws -> Void
    }
}

extension Newsletter.Client: TestDependencyKey {
    public static let testValue: Newsletter.Client = .testValue
}

extension Newsletter.Client {
    @DependencyClient
    public struct Subscribe: @unchecked Sendable {
        @DependencyEndpoint
        public var request: (EmailAddress) async throws -> Void
        @DependencyEndpoint
        public var verify: (_ token: String, _ email: EmailAddress) async throws -> Void
    }
}

extension Newsletter.Client.Subscribe: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { _ in print("requested subscriptions") },
            verify: { _, _ in print("verified subscription") }
        )
    }
}
