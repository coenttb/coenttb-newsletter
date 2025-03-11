//
//  File.swift
//  coenttb-newsletter
//
//  Created by Coen ten Thije Boonkkamp on 11/03/2025.
//

import Foundation
import Coenttb_Web
import Mailgun
import Messages

extension Email {
    public static func requestEmailVerification(
        verificationUrl: URL,
        businessName: String,
        supportEmail: EmailAddress,
        from: EmailAddress,
        to user: EmailAddress,
        primaryColor: HTMLColor
    ) -> Self {

        let html = TableEmailDocument(
            preheader: TranslatedString(
                dutch: "Verifiëer je emailadres voor de nieuwsbrief van \(businessName)",
                english: "Verify your email for the newsletter of \(businessName)"
            ).description
        ) {
            tr {
                td {
                    VStack(alignment: .leading) {
                        Header(3) {
                            TranslatedString(
                                dutch: "Verifiëer je emailadres",
                                english: "Verify your email address"
                            )
                        }

                        Paragraph {
                            TranslatedString(
                                dutch: "Bevestig alsjeblieft dat dit je e-mailadres is.",
                                english: "Please verify that this is your email address."
                            )
                        }
                        .padding(bottom: .extraSmall)
                        .fontSize(.body)

                        Button(
                            tag: a,
                            background: primaryColor
                        ) {
                            TranslatedString(
                                dutch: "Verifieer e-mailadres",
                                english: "Verify email address"
                            )
                        }
                        .color(.primary.reverse())
                        .href(verificationUrl.absoluteString)
                        .padding(bottom: Length.medium)

                        Paragraph(.small) {

                            TranslatedString(
                                dutch: "Om veiligheidsredenen verloopt deze verificatielink binnen 24 uur.",
                                english: "This verification link will expire in 24 hours for security reasons. "
                            )

                            TranslatedString(
                                dutch: "Als je deze aanvraag niet hebt gedaan, kun je deze e-mail negeren.",
                                english: "If you did not make this request, please disregard this email."
                            )

                            br()

                            TranslatedString(
                                dutch: "Voor hulp, neem contact op met ons op via \(supportEmail).",
                                english: "For help, contact us at \(supportEmail)."
                            )
                        }
                        .fontSize(.footnote)
                        .color(.secondary)
                    }
                    .padding(vertical: .small, horizontal: .medium)
                }
            }
        }
            .backgroundColor(.primary.reverse())

        let subjectAdd = TranslatedString(
            dutch: "Verifieer je e-mailadres",
            english: "Verify your email address"
        )

        let bytes: ContiguousArray<UInt8> = html.render()
        let string: String = String(decoding: bytes, as: UTF8.self)

        return .init(
            from: from,
            to: [ user ],
            subject: "\(businessName) | \(subjectAdd)",
            html: string,
            text: verificationUrl.absoluteString
        )
    }
}
