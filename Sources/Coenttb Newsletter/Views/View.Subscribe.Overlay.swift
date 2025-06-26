//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 28/08/2024.
//

import Coenttb_Web

extension View.Subscribe {
    public struct Overlay: HTML {
        let image: HTMLElementTypes.Image
        let title: String
        let caption: String
        let newsletterSubscribed: Bool
        let buttonId = UUID()
        
        public init(
            image: HTMLElementTypes.Image,
            title: String,
            caption: String,
            newsletterSubscribed: Bool
        ) {
            var image = image
            image.loading = .lazy
            self.image = image
            self.title = title
            self.caption = caption
            self.newsletterSubscribed = newsletterSubscribed
        }
        
        @Dependency(\.newsletter.subscribeOverlayId) var subscribeOverlayId
        @Dependency(\.newsletter.saveToLocalstorage) var saveToLocalstorage
        @Dependency(\.newsletter.subscribeAction) var subscribeAction
        
        public var body: some HTML {
            if newsletterSubscribed != true {
                Coenttb_Web.Overlay(id: subscribeOverlayId()) {
                    VStack(spacing: 0.5.rem) {
                        div {
                            div {
                                image
                                    .halftone(
                                        dotSize: .px(3),
                                        lineColor: .black
                                    )
                            }
                            .clipPath(.circle(.percent(50)))
                            .position(.relative)
                            .size(.rem(5))
                        }
                        .flexContainer(
                            justification: .center,
                            itemAlignment: .center
                        )
                        .margin(top: .length(.medium))
                        .margin(bottom: .length(.small))
                        
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
}

