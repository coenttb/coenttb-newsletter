//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2024.
//

import Coenttb_Newsletter
import Coenttb_Vapor
import Coenttb_Web

extension Newsletter.Route.View {
    public static func response(
        newsletter: Newsletter.Route.View,
        htmlDocument: (any HTML) -> any (HTMLDocumentProtocol & AsyncResponseEncodable)
    ) async throws -> any AsyncResponseEncodable {
        switch newsletter {
        case .subscribe(let subscribe):
            switch subscribe {
            case .request:
                return htmlDocument(
                    AnyHTML(
                        Newsletter.Route.View.Subscribe.Request()
                    )
                )
            case .verify(let verify):
                @Dependency(\.newsletter.verificationAction) var verificationAction
                return htmlDocument(
                    AnyHTML(
                        Newsletter.Route.View.Verify(
                            verificationAction: verificationAction(verify)
                        )
                    )
                )
            }
        case .unsubscribe:
            return htmlDocument(
                AnyHTML(
                    VStack {
                        Newsletter.Route.View.Unsubscribe()
                    }
                        .margin(vertical: .rem(3))
                )
            )
        }
    }
}
