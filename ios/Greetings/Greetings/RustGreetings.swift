//
//  RustGreetings.swift
//  Greetings
//
//  Created by youerwei on 2022/5/17.
//

import Foundation

class RustGreetings {
    func sayHello(to: String) -> String {
        let result = rust_greeting(to);
        let switft_result = String(cString: result!);
        rust_greeting_free(UnsafeMutablePointer(mutating: result));
        return switft_result;
    }
}
