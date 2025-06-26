//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2024.
//

import Coenttb_Newsletter
import Coenttb_Web
import Coenttb_Vapor

extension Coenttb_Newsletter.View {
    public static func response(
        newsletter: Coenttb_Newsletter.View,
        htmlDocument: (any HTML) -> any (HTMLDocumentProtocol & AsyncResponseEncodable)
    ) async throws -> any AsyncResponseEncodable {
        switch newsletter {
        case .subscribe(let subscribe):
            switch subscribe {
            case .request:
                return htmlDocument (
                    AnyHTML(
                        View.Subscribe.Request()
                    )
                )
            case .verify(let verify):
                @Dependency(\.newsletter.verificationAction) var verificationAction
                return htmlDocument (
                    AnyHTML(
                        View.Verify(
                            verificationAction: verificationAction(verify)
                        )
                    )
                )
            }
        case .unsubscribe:
            return htmlDocument (
                AnyHTML(
                    VStack {
                        View.Unsubscribe()
                    }
                        .margin(vertical: 3.rem)
                )
            )
        }
    }
}
