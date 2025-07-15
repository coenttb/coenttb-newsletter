//
//  File.swift
//  coenttb-newsletter
//
//  Created by Coen ten Thije Boonkkamp on 11/03/2025.
//

import EmailAddress
import Foundation

extension Newsletter.Route.API.Subscribe {
    public struct Verification: Codable, Hashable, Sendable {
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

extension Newsletter.Route.API.Subscribe.Verification {
    public init(
        token: String,
        email: EmailAddress
    ) {
        self.token = token
        self.email = email.rawValue
    }
}
