//
//  File.swift
//  coenttb-newsletter
//
//  Created by Coen ten Thije Boonkkamp on 15/07/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
@dynamicMemberLookup
public struct Newsletter: Sendable {
    public var client: Newsletter.Client
    public var configuration: Newsletter.Configuration

    public init(
        client: Newsletter.Client,
        configuration: Newsletter.Configuration
    ) {
        self.client = client
        self.configuration = configuration
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Newsletter.Client, T>) -> T {
        self.client[keyPath: keyPath]
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Newsletter.Configuration, T>) -> T {
        self.configuration[keyPath: keyPath]
    }
}
