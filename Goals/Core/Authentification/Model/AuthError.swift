//
//  AuthError.swift
//  Goals
//
//  Created by Work on 24/12/2023.
//

//import Firebase
//
//enum AuthError: Error {
//    case invalidEmail
//    case invalidPassword
//    case userNotFound
//    case weakPassword
//    case unknown
//    case custom(message: String) // Add a custom case for general error messages
//
//    init(authErrorCode: AuthErrorCode) {
//        switch authErrorCode {
//        case .invalidEmail:
//            self = .invalidEmail
//        case .wrongPassword:
//            self = .invalidPassword
//        case .weakPassword:
//            self = .weakPassword
//        case .userNotFound:
//            self = .userNotFound
//        default:
//            self = .unknown
//        }
//    }
//    
//    init(message: String) {
//        self = .custom(message: message)
//    }
//    
//    var description: String {
//        switch self {
//        case .invalidEmail:
//            return "The email you entered is invalid. Please try again."
//        case .invalidPassword:
//            return "Incorrect password. Please try again."
//        case .userNotFound:
//            return "No account found with this email. Please sign up to continue."
//        case .weakPassword:
//            return "Your password is too weak. It must be at least 6 characters long."
//        case .unknown:
//            return "An unknown error occurred. Please try again."
//        case .custom(let message):
//            return message
//        }
//    }
//}
