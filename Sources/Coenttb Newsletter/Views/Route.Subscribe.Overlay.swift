//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 28/08/2024.
//

import Coenttb_Web

extension Route.Subscribe {
    public struct Overlay: HTML {
        let overlay_id:String
        let saveToLocalstorage: Bool
        let image: Image
        let title: String
        let caption: String
        let newsletterSubscribed: Bool
        let newsletterSubscribeAction: URL
        
        public init(
            overlay_id: String = "tenthijeboonkkampnewslettersubscriptionoverlay",
            saveToLocalstorage: Bool = true,
            image: Image,
            title: String,
            caption: String,
            newsletterSubscribed: Bool,
            newsletterSubscribeAction: URL
        ) {
            self.overlay_id = overlay_id
            self.saveToLocalstorage = saveToLocalstorage
            self.image = image
            self.title = title
            self.caption = caption
            self.newsletterSubscribed = newsletterSubscribed
            self.newsletterSubscribeAction = newsletterSubscribeAction
        }
        
        public var body: some HTML {
            if newsletterSubscribed != true {
                Coenttb_Web.Overlay(id: overlay_id) {
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
                            newsletterSubscribeAction: newsletterSubscribeAction
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
                        hideOverlay_\(String.sanitizeForJavaScript(overlay_id))(\(saveToLocalstorage))
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


