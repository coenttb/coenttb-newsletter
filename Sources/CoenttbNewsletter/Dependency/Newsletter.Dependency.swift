//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2024.
//

import CoenttbWebDependencies
import EmailAddress
import Foundation
import CoenttbWebHTML
import Mailgun

@DependencyClient
public struct Client: @unchecked Sendable {
    
    public var subscribe: CoenttbNewsletter.Client.Subscribe

    @DependencyEndpoint
    public var unsubscribe: (EmailAddress) async throws -> Void
}

extension Client: TestDependencyKey {
    public static let testValue: Client = .testValue
}

extension CoenttbNewsletter.Client {
    @DependencyClient
    public struct Subscribe: @unchecked Sendable {
        @DependencyEndpoint
        public var request: (EmailAddress) async throws -> Void
        @DependencyEndpoint
        public var verify: (_ token: String, _ email: String) async throws -> Void
    }
}

extension CoenttbNewsletter.Client.Subscribe: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { _ in print("requested subscriptions") },
            verify: { _, _ in print("verified subscription") }
        )
    }
}
