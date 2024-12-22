//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 05/09/2024.
//

import CoenttbWebHTML
//import Date
import Dependencies
import Foundation
import CoenttbHTML
import Languages
import CoenttbWebTranslations

extension Route.Unsubscribe {
    public struct View: HTML {

        let form_id: String
        let localStorageKey: String
        let newsletterUnsubscribeAction: URL
        
        public init(
            form_id: String,
            localStorageKey: String,
            newsletterUnsubscribeAction: URL
        ) {
            self.form_id = form_id
            self.localStorageKey = localStorageKey
            self.newsletterUnsubscribeAction = newsletterUnsubscribeAction
        }
        
        public var body: some HTML {
            PageModule(theme: .newsletterSubscription) {
                VStack {
                    NewsletterUnsubscriptionForm(
                        localStorageKey: self.localStorageKey,
                        newsletterUnsubscribeAction: self.newsletterUnsubscribeAction
                    )
                }
                .maxWidth(30.rem)
                .flexContainer(
                    direction: .column,
                    wrap: .wrap,
                    justification: .center,
                    itemAlignment: .center,
                    rowGap: .length(0.5.rem)
                )
            }
            title: {
                Header(4) {
                    String.unsubscribe.capitalizingFirstLetter()
                }
            }
            .flexContainer(
                justification: .center,
                itemAlignment: .center
            )
        }
    }
}

public struct NewsletterUnsubscriptionForm: HTML {
    let localStorageKey: String
    let newsletterUnsubscribeAction: URL

    public init(
        localStorageKey: String,
        newsletterUnsubscribeAction: URL
    ) {
        self.localStorageKey = localStorageKey
        self.newsletterUnsubscribeAction = newsletterUnsubscribeAction
    }

    let form_id = "NewsletterUnsubscriptionFormId"

    public var body: some HTML {
        form {
            VStack {
                Input.default(CoenttbNewsletter.API.Unsubscribe.CodingKeys.email)
                    .type(.email)
                    .value("")
                    .placeholder(
                        "\(String.type_your_email.capitalizingFirstLetter())..."
                    )

                div {
                    Button(
                        tag: button
                    ) {
                        "\(String.unsubscribe.capitalizingFirstLetter())"
                    }
                    .type(.submit)
                    .display(.inlineBlock)
                }
                .flexContainer(
                    justification: .center,
                    itemAlignment: .center,
                    media: .desktop
                )
                
                div()
                    .id("\(form_id)-message")
            }
        }
        .id(form_id)
        .method(.post)
//        .action(serverRouter.url(for: .api(.v1(.newsletter(.unsubscribe(.init(value: "")))))).absoluteString)
        .action(newsletterUnsubscribeAction.absoluteString)

        script {
            """
            document.addEventListener('DOMContentLoaded', function() {
                const form = document.getElementById("\(form_id)");
                const formContainer = form;
                const localStorageKey = "\(localStorageKey)";

                form.addEventListener('submit', async function(event) {
                    event.preventDefault();

                    const formData = new FormData(form);
                    const email = formData.get('\(CoenttbNewsletter.API.Unsubscribe.CodingKeys.email.rawValue)');

                    try {
                        const response = await fetch(form.action, {
                            method: form.method,
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                                'Accept': 'application/json'
                            },
                            body: new URLSearchParams({ \(CoenttbNewsletter.API.Unsubscribe.CodingKeys.email.rawValue): email }).toString()
                        });

                        if (!response.ok) {
                            throw new Error('Network response was not ok');
                        }

                        const data = await response.json();

                        if (data.success) {
                            localStorage.removeItem(localStorageKey);

                            formContainer.innerHTML = `\(String(decoding: successSection.render(), as: UTF8.self))`;
                        } else {
                            throw new Error(data.message || 'Unsubscription failed');
                        }
            
                    } catch (error) {
                        console.error('Error:', error);
                        const messageDiv = document.createElement('div');
                        messageDiv.textContent = 'An error occurred. Please try again.';
                        messageDiv.style.color = 'red';
                        messageDiv.style.textAlign = 'center';
                        messageDiv.style.marginTop = '10px';
                        form.appendChild(messageDiv);
                    }
                });
            });
            """
        }
    }
    
    @HTMLBuilder
    var successSection: some HTML {
        VStack {
            Header(3) {
                "Successfully unsubscribed"
            }
            .color(.red)
            
            Paragraph {
                "You have been unsubscribed from our newsletter. We're sorry to see you go!"
            }
        }
        .textAlign(.center, media: .desktop)
    }
}
