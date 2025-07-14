//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 28/08/2024.
//

import Coenttb_Web

extension View.Subscribe {
    public struct Overlay: HTML {
        let image: (() -> HTMLElementTypes.Image)?
        let title: String
        let caption: String
        let buttonId = UUID()
        
        public init(
            title: String,
            caption: String,
            image: (() -> HTMLElementTypes.Image)? = nil
        ) {
            self.image = image
            self.title = title
            self.caption = caption
        }
        
        @Dependency(\.newsletter.subscribeOverlayId) var subscribeOverlayId
        @Dependency(\.newsletter.saveToLocalstorage) var saveToLocalstorage
        @Dependency(\.newsletter.subscribeAction) var subscribeAction
        
        public var body: some HTML {
            Coenttb_Web.Overlay(id: subscribeOverlayId()) {
                VStack(spacing: 0.5.rem) {
                    
                    if let image {
                        image()
                            .size(.rem(10)) // Make sure this is 10rem, not smaller
                            .position(.relative)
                            .flexContainer(
                                justification: .center,
                                itemAlignment: .center
                            )
                            .margin(top: .length(.medium))
                            .margin(bottom: .length(.small))
                    }
                    
                    div {
                        Header(4) {
                            HTMLText(title)
                        }
                    }
                    
                    CoenttbHTML.Paragraph {
                        HTMLText(caption.capitalizingFirstLetter().period.description)
                    }
                    
                    NewsletterSubscriptionForm(
                        subscribeAction: subscribeAction()
                    )
                    
                    div{
                        Divider()
                    }
                    
                    Link(
                        .continue_reading.capitalizingFirstLetter().description,
                        href: nil
                    )
                        .font(.body(.small))
                        .cursor(.pointer)
                        .id(buttonId.uuidString)
                        .padding(.length(.extraSmall))
                }
                
                script {
                """
                (() => {
                    const btn = document.getElementById('\(buttonId.uuidString)');
                    if (!btn) return;
                    btn.addEventListener('click', (e) => {
                        e.preventDefault();
                        hideOverlay_\(String.sanitizeForJavaScript(subscribeOverlayId()))(\(saveToLocalstorage));
                    });
                })();
                """
                }
            }
        }
    }
}

