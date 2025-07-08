//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 28/08/2024.
//

import Coenttb_Web

extension View.Subscribe {
    public struct Request: HTML {
        
        public init(
        ) {
            
        }
        @Dependency(\.newsletter.subscribeFormId) var subscribeFormId
        @Dependency(\.newsletter.subscribeCaption) var caption
        @Dependency(\.newsletter.subscribeAction) var subscribeAction
        
        public var body: some HTML {
            PageModule(theme: .newsletterSubscription) {
                VStack {
                    CoenttbHTML.Paragraph {
                        HTMLText(caption())
                    }
                    .textAlign(.center)
                    
                    NewsletterSubscriptionForm(form_id: subscribeFormId(), subscribeAction: subscribeAction())
                }
                .maxWidth(.rem(30), media: .desktop)
                .flexContainer(
                    direction: .column,
                    wrap: .wrap,
                    justification: .center,
                    itemAlignment: .center,
                    rowGap: .rem(0.5)
                )
            }
            title: {
                Header(4) {
                    String.subscribe_to_my_newsletter.capitalizingFirstLetter()
                }
            }
            .flexContainer(
                justification: .center,
                itemAlignment: .center
            )
        }
    }
}

extension PageModule.Theme {
    public static var newsletterSubscription: Self {
        Self(
            topMargin: .rem(0),
            bottomMargin: .length(.large),
            leftRightMargin: .length(.medium),
            leftRightMarginDesktop: .length(.large),
            itemAlignment: .center
        )
    }
}

public struct NewsletterSubscriptionForm: HTML {
    let form_id: String
    let subscribeAction: URL
    
    public init(
        form_id: String = UUID().uuidString,
        subscribeAction: URL
    ) {
        self.form_id = form_id
        self.subscribeAction = subscribeAction
    }
    
    public var body: some HTML {
        form(
            action: .init(subscribeAction.absoluteString),
            method: .post
        ) {
            VStack {

                Input(
                    codingKey: Request.CodingKeys.email,
                    type: .email(
                        .init(
                            value: "",
                            maxlength: nil,
                            minlength: nil,
                            required: nil,
                            multiple: nil,
                            pattern: nil,
                            placeholder: .init("\(String.type_your_email.capitalizingFirstLetter())..."),
                            readonly: nil,
                            size: nil
                        )
                    )
                )
                div {
                    Button(
                        type: .submit
                    ) {
                        "\(String.subscribe.capitalizingFirstLetter())"
                    }
                    .color(.text.secondary)
                    .display(.inlineBlock)
                }
                .flexContainer(
                    justification: .center,
                    itemAlignment: .center,
                    media: .desktop
                )
                                
                div() {}
                    .id("\(form_id)-message")
            }
        }
        .id(form_id)

        script {
            """
            document.addEventListener('DOMContentLoaded', function() {
                const form = document.getElementById("\(form_id)");
                const formContainer = form;

                form.addEventListener('submit', async function(event) {
                    event.preventDefault();

                    const formData = new FormData(form);
                    const email = formData.get('\(Request.CodingKeys.email.rawValue)');

                    try {
                        const response = await fetch(form.action, {
                            method: form.method,
                            headers: {
                                'Content-Type': 'application/x-www-form-urlencoded',
                                'Accept': 'application/json'
                            },
                            body: new URLSearchParams({ \(Request.CodingKeys.email.rawValue): email }).toString()
                        });

                        if (!response.ok) {
                            throw new Error('Network response was not ok');
                        }

                        const data = await response.json();

                        if (data.success) {
                            formContainer.innerHTML = \(html: successSection);
                            console.log(formContainer.innerHTML)
                        } else {
                            throw new Error(data.message || 'Subscription failed');
                        }
            
                    } catch (error) {
                        console.error('Error:', error);
                        const existing = form.querySelector('.error-message');
                        if (existing) {
                            existing.remove();
                        }

                        // Create and style new error message
                        const messageDiv = document.createElement('div');
                        messageDiv.className = 'error-message';
                        messageDiv.textContent = `An error occurred: ${error.message || error}`;
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
                TranslatedString(
                    dutch: "Controleer je e-mail",
                    english: "Check your email"
                )
            }
            .color(.blue)
            
            CoenttbHTML.Paragraph {
                TranslatedString(
                    dutch: "Controleer je inbox voor een verificatie-e-mail. Klik op de link in de e-mail om je inschrijving te voltooien",
                    english: "Please check your inbox for a verification email. Click the link in the email to complete your subscription"
                ).period
            }
            
            CoenttbHTML.Paragraph {
                TranslatedString(
                    dutch: "Als je de e-mail niet ziet, controleer dan je spam-map",
                    english: "If you don't see the email, please check your spam folder"
                ).period
            }
            .font(.body(.small))
            .color(.gray100)
        }
        .textAlign(.center, media: .desktop)
    }
}

#if DEBUG && canImport(SwiftUI)
import SwiftUI

#Preview {
    HTMLDocument {
        NewsletterSubscriptionForm(subscribeAction: .init(string: "#")!)
    }
}
#endif
