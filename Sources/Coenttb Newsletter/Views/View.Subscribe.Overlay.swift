//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 28/08/2024.
//

import Coenttb_Web

extension View.Subscribe {
    public struct Overlay: HTML {
        let image: Image
        let title: String
        let caption: String
        let newsletterSubscribed: Bool
        
        public init(
            image: Image,
            title: String,
            caption: String,
            newsletterSubscribed: Bool
        ) {
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
                                    .loading(.lazy)
                                    .halftone(dotSize: 3.px)
                            }
                            .clipPath(.circle(50.percent))
                            .position(.relative)
                            .size(5.rem)
                        }
                        .flexContainer(
                            justification: .center,
                            itemAlignment: .center
                        )
                        .margin(top: .medium)
                        .margin(bottom: .small)
                        
                        div {
                            Header(4) {
                                HTMLText(title)
                            }
                        }
                        
                        Paragraph {
                            HTMLText(caption.capitalizingFirstLetter().period.description)
                        }
                        
                        NewsletterSubscriptionForm(
                            subscribeAction: subscribeAction()
                        )
                        
                        div{
                            Divider()
                        }
                        
                        Link(.continue_reading.capitalizingFirstLetter().description, href: nil)
                            .fontStyle(.body(.small))
                            .cursor(.pointer)
                            .onclick("continueReading()")
                            .padding(.extraSmall)
                    }
                    
                    script {
                    """
                    function continueReading() {
                        // dismissOverlay();
                        hideOverlay_\(String.sanitizeForJavaScript(subscribeOverlayId()))(\(saveToLocalstorage))
                        console.log("test")
                    }
                    
                    function subscribe() {
                        // alert('Thank you for subscribing!');
                        // dismissOverlay();
                    }
                    """
                    }
                }
            }
        }
    }
}


