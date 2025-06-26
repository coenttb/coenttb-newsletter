//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 18/12/2024.
//

import Coenttb_Web

extension View {
    public struct Verify: HTML {
        
        @Dependency(\.newsletter.verificationRedirectURL) var verificationRedirectURL
        
        let verificationAction: URL
        
        public init(
            verificationAction: URL
        ) {
            self.verificationAction = verificationAction
        }
        
        private static let pagemodule_verify_id: String = "pagemodule_verify_id"
        
        public var body: some HTML {
            HTMLEmpty()
//            PageModule(theme: .login) {
//                VStack(alignment: .center) {
//                    div() { }
//                        .id("spinner")
//                    h2 { "message" }
//                        .id("message")
//                }
//                .textAlign(.center)
//                .alignItems(.center)
//                .textAlign(.start, media: .mobile)
//                .alignItems(.leading, media: .mobile)
//                .width(.percent(100))
//                .maxWidth(.rem(20))
//                .maxWidth(.rem(24), media: .mobile)
//                .margin(vertical: nil, horizontal: .auto)
//                
//            } title: {
//                Header(3) {
//                    TranslatedString(
//                        dutch: "Verificatie in uitvoering...",
//                        english: "Verification in Progress..."
//                    )
//                }
//                .display(.inlineBlock)
//                .textAlign(.center)
//            }
//            .id(Self.pagemodule_verify_id)
//            
//            script {"""
//                document.addEventListener('DOMContentLoaded', function() {
//                    const urlParams = new URLSearchParams(window.location.search);
//                    const token = urlParams.get('token');
//                    const email = urlParams.get('email');
//                    
//                    if (token && email) {
//                        verifyEmail(token, email); // Pass both token and email to the function
//                    } else {
//                        showMessage('Error: No verification token or email found.', false);
//                    }
//                });
//            
//                async function verifyEmail(token, email) {
//                    try {
//                        // Create a URL object from the verificationAction
//                        const url = new URL('\(verificationAction.absoluteString)');
//                        
//                        // Update or add the token and email parameters
//                        url.searchParams.set('token', token);
//                        url.searchParams.set('email', email);
//            
//                        const response = await fetch(url.toString(), {
//                            method: 'POST'
//                        });
//                        const data = await response.json();
//                        
//                       
//                        if (data.success) {
//                            const pageModule = document.getElementById("\(Self.pagemodule_verify_id)");
//                            pageModule.outerHTML = "\(html: Verify.ConfirmationPage(redirectURL: verificationRedirectURL()))";
//                            setTimeout(() => { window.location.href = '\(verificationRedirectURL().absoluteString)'; }, 5000);
//
//                        } else {
//                            throw new Error(data.message || 'Account creation failed');
//                        }
//                    } catch (error) {
//                        console.error("Error occurred:", error);
//                        showMessage('An error occurred during verification. Please try again later.', false);
//                    }
//                }
//            
//                function showMessage(message, isSuccess) {
//                    const messageElement = document.getElementById('message');
//                    const spinnerElement = document.getElementById('spinner');
//                    messageElement.textContent = message;
//                    messageElement.className = isSuccess ? 'success' : 'error';
//                    spinnerElement.style.display = 'none';
//                }
//            """}
        }
    }
}

extension View.Verify {
    public struct ConfirmationPage: HTML {
        let redirectURL: URL
        
        public init(redirectURL: URL) {
            self.redirectURL = redirectURL
        }
        
        public var body: some HTML {
            HTMLEmpty()
//            PageModule(theme: .login) {
//                VStack(alignment: .center) {
//                    Paragraph {
//                        TranslatedString(
//                            dutch: "Uw email is succesvol geverifieerd!",
//                            english: "Your email has been successfully verified!"
//                        )
//                    }
//                    .textAlign(.center)
//                    .marginBottom(.rem(1))
//                    
//                    Paragraph {
//                        TranslatedString(
//                            dutch: "U wordt over 5 seconden doorgestuurd naar de inlogpagina.",
//                            english: "You will be redirected to the login page in 5 seconds."
//                        )
//                    }
//                    .textAlign(.center)
//                    .margin(bottom: .rem(2))
//                    
//                    Link(href: redirectURL.absoluteString) {
//                        TranslatedString(
//                            dutch: "Klik hier als u niet automatisch wordt doorgestuurd",
//                            english: "Click here if you are not redirected automatically"
//                        )
//                    }
//                    .linkColor(.text.primary)
//                }
//                .textAlign(.center)
//                .alignItems(.center)
//                .width(.percent(100))
//                .maxWidth(.rem(20))
//                .maxWidth(.rem(24), media: .mobile)
//                .margin(vertical: nil, horizontal: .auto)
//            } title: {
//                Header(3) {
//                    "Email verified"
//                }
//                .display(.inlineBlock)
//                .textAlign(.center)
//            }
        }
    }
}



extension PageModule.Theme {
    static var login: Self {
        Self(
            topMargin: .rem(10),
            bottomMargin: .rem(4),
            leftRightMargin: .rem(2),
            leftRightMarginDesktop: .rem(3),
            itemAlignment: .center
        )
    }
}
