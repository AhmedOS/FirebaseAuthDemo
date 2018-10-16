//
//  API.swift
//  FirebaseDemo
//
//  Created by Ahmed Osama on 10/16/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation

class API {
    
    private init() { }
    
    private static let apiKey = ""
    static let signUpEndPoint = "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=\(apiKey)"
    
    static let countriesEndPoint = "https://restcountries.eu/rest/v2/all"
    
    static func countryFlagImageURL(code: String) -> String {
        return "https://www.countryflags.io/" + code + "/flat/64.png"
    }
    
}
