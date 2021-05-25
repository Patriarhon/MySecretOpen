//
//  AuthorizationModule.swift
//  My Secret
//
//  Created by Petr on 17.05.2020.
//  Copyright © 2020 Petr. All rights reserved.
//

import Foundation
import FirebaseAuth

extension API {
    class AuthorizationModule {
        private static var verificationID: String?
        
        static func verifyPhone(number: String, success: @escaping (String?) -> (), failure: @escaping (Error) -> ()) {
            PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    failure(error)
                }
                
                Self.verificationID = verificationID
                success(verificationID)
            }
        }
        
        static func send(code: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID ?? "", verificationCode: code)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    failure(error)
                    return
                }
                success()
            }
        }
        
        static func signIn(email: String, password: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                //          guard let strongSelf = self else { return }
                // ...
                if let error = error {
                    failure(error)
                    return
                }
                success()
            }
        }
        
        static func createUser(email: String, password: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if let error = error {
                    failure(error)
                    return
                }
                success()
            }
        }
        
        static func resetPassword(email: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
            Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                if let error = error {
                    failure(error)
                    return
                }
                success()
            })
        }
    }
    
}
