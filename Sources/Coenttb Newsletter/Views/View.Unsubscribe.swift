//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 05/09/2024.
//

import Coenttb_Web

extension View {
    public struct Unsubscribe: HTML {
        
        @Dependency(\.newsletter.localStorageKey) var localStorageKey
        @Dependency(\.newsletter.unsubscribeAction) var unsubscribeAction
        @Dependency(\.newsletter.unsubscribeFormId) var unsubscribeFormId
        
        public init(
            
        ) {
            
        }
        
        public var body: some HTML {
            HTMLEmpty()
//            PageModule(theme: .newsletterSubscription) {
//                VStack {
//                    NewsletterUnsubscriptionForm()
//                }
//                .maxWidth(.rem(30))
//                .flexContainer(
//                    direction: .column,
//                    wrap: .wrap,
//                    justification: .center,
//                    itemAlignment: .center,
//                    rowGap: .length(.rem(0.5))
//                )
//            }
//            title: {
//                Header(4) {
//                    String.unsubscribe.capitalizingFirstLetter()
//                }
//            }
//            .flexContainer(
//                justification: .center,
//                itemAlignment: .center
//            )
        }
    }
}

public struct NewsletterUnsubscriptionForm: HTML {
    
    @Dependency(\.newsletter.localStorageKey) var localStorageKey
    @Dependency(\.newsletter.unsubscribeAction) var unsubscribeAction
    @Dependency(\.newsletter.unsubscribeFormId) var unsubscribeFormId

    public init(
        
    ) {
        
    }
    
    public var body: some HTML {
        HTMLEmpty()
//        form(
//            action: .init(unsubscribeAction().absoluteString),
//            method: .post
//        ) {
//            VStack {
//                Input(
//                    codingKey: Coenttb_Newsletter.API.Unsubscribe.CodingKeys.email,
//                    type: .email(
//                        .init(
//                            value: "",
//                            maxlength: nil,
//                            minlength: nil,
//                            required: nil,
//                            multiple: nil,
//                            pattern: nil,
//                            placeholder: .init("\(String.type_your_email.capitalizingFirstLetter())..."),
//                            readonly: nil,
//                            size: nil
//                        )
//                    )
//                )
//                
//
//
////                div {
////                    Button(
////                        tag: button
////                    ) {
////                        "\(String.unsubscribe.capitalizingFirstLetter())"
////                    }
////                    .type(.submit)
////                    .display(.inlineBlock)
////                }
////                .flexContainer(
////                    justification: .center,
////                    itemAlignment: .center,
////                    media: .desktop
////                )
//                
//                div() {}
//                    .id("\(unsubscribeFormId())-message")
//            }
//        }
//        .id(unsubscribeFormId())
//
//        script {
//            """
//            document.addEventListener('DOMContentLoaded', function() {
//                const form = document.getElementById("\(unsubscribeFormId())");
//                const formContainer = form;
//                const localStorageKey = "\(localStorageKey())";
//
//                form.addEventListener('submit', async function(event) {
//                    event.preventDefault();
//
//                    const formData = new FormData(form);
//                    const email = formData.get('\(Coenttb_Newsletter.API.Unsubscribe.CodingKeys.email.rawValue)');
//
//                    try {
//                        const response = await fetch(form.action, {
//                            method: form.method,
//                            headers: {
//                                'Content-Type': 'application/x-www-form-urlencoded',
//                                'Accept': 'application/json'
//                            },
//                            body: new URLSearchParams({ \(Coenttb_Newsletter.API.Unsubscribe.CodingKeys.email.rawValue): email }).toString()
//                        });
//
//                        if (!response.ok) {
//                            throw new Error('Network response was not ok');
//                        }
//
//                        const data = await response.json();
//
//                        if (data.success) {
//                            localStorage.removeItem(localStorageKey);
//
//                            formContainer.innerHTML = `\(String(decoding: successSection.render(), as: UTF8.self))`;
//                        } else {
//                            throw new Error(data.message || 'Unsubscription failed');
//                        }
//            
//                    } catch (error) {
//                        console.error('Error:', error);
//                        const messageDiv = document.createElement('div');
//                        messageDiv.textContent = 'An error occurred. Please try again.';
//                        messageDiv.style.color = 'red';
//                        messageDiv.style.textAlign = 'center';
//                        messageDiv.style.marginTop = '10px';
//                        form.appendChild(messageDiv);
//                    }
//                });
//            });
//            """
//        }
    }
    
    @HTMLBuilder
    var successSection: some HTML {
        HTMLEmpty()
//        VStack {
//            Header(3) {
//                "Successfully unsubscribed"
//            }
//            .color(.red)
//            
//            CoenttbHTML.Paragraph {
//                "You have been unsubscribed from our newsletter. We're sorry to see you go!"
//            }
//        }
//        .textAlign(
//            .center,
//            media: .desktop
//        )
    }
}
