//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2024.
//

import Coenttb_Newsletter
import Coenttb_Web
import Coenttb_Vapor

extension Coenttb_Newsletter.Route {
    public static func response<
        HTMLDoc: HTMLDocument & AsyncResponseEncodable
    >(
        newsletter: Coenttb_Newsletter.Route,
        htmlDocument: (any HTML) -> HTMLDoc,
        subscribeCaption: () -> String,
        subscribeAction: () -> URL,
        verificationAction: (Coenttb_Newsletter.Route.Subscribe.Verify) -> URL,
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
                        Coenttb_Newsletter.Route.Subscribe.View(
                            caption: subscribeCaption(),
                            newsletterSubscribeAction: subscribeAction()
                        )
                    )
                )
            case .verify(let verify):
                return htmlDocument (
                    AnyHTML(
                        Coenttb_Newsletter.Verify(
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
                        Coenttb_Newsletter.Route.Unsubscribe.View(
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
