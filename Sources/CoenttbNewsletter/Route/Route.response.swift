//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2024.
//

import CoenttbMarkdown
import CoenttbWebHTML
import Dependencies
import Foundation
import Languages
import CoenttbVapor

extension CoenttbNewsletter.Route {
    public static func response<
        HTMLDoc: HTMLDocument & AsyncResponseEncodable
    >(
        newsletter: CoenttbNewsletter.Route,
        htmlDocument: (any HTML) -> HTMLDoc,
        subscribeCaption: () -> String,
        subscribeAction: () -> URL,
        verificationAction: (Route.Subscribe.Verify) -> URL,
        verificationRedirectURL: () -> URL,
        newsletterUnsubscribeAction: () -> URL,
        form_id: () -> String,
        localStorageKey: () -> String
    ) async throws -> any AsyncResponseEncodable {
        switch newsletter {
        case .subscribe(let subscribe):
            switch subscribe {
            case .request:
                return htmlDocument (
                    AnyHTML(
                        CoenttbNewsletter.Route.Subscribe.View(
                            caption: subscribeCaption(),
                            newsletterSubscribeAction: subscribeAction()
                        )
                    )
                )
            case .verify(let verify):
                return htmlDocument (
                    AnyHTML(
                        CoenttbNewsletter.Verify(
                            verificationAction: verificationAction(verify),
                            redirectURL: verificationRedirectURL()
                        )
                    )
                )
            }
        case .unsubscribe:
            return htmlDocument (
                AnyHTML(
                    VStack {
                        CoenttbNewsletter.Route.Unsubscribe.View(
                            form_id: form_id(),
                            localStorageKey: localStorageKey(),
                            newsletterUnsubscribeAction: newsletterUnsubscribeAction()
                        )
                    }
                        .margin(vertical: 3.rem)
                )
            )
        }
    }
}
