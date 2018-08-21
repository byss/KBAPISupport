//
//  KBAPIParametersProviding.swift
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public protocol KBAPIParametersProviding {
	associatedtype Parameters = VoidParameters where Parameters: Encodable;
	
	typealias VoidParameters = KBAPIRequestVoidParameters;
	
	var parameters: Parameters { get }
}

public extension KBAPIParametersProviding where Parameters == VoidParameters {
	public var parameters: Parameters {
		return Parameters ();
	}
}

public extension KBAPIParametersProviding where Parameters: ExpressibleByNilLiteral {
	public var parameters: Parameters {
		return nil;
	}
}

public extension KBAPIParametersProviding where Parameters: ExpressibleByArrayLiteral {
	public var parameters: Parameters {
		return Parameters ();
	}
}

public extension KBAPIParametersProviding where Parameters: ExpressibleByDictionaryLiteral {
	public var parameters: Parameters {
		return Parameters ();
	}
}

public struct KBAPIRequestVoidParameters: Encodable, CustomStringConvertible {
	public var description: String {
		return "none";
	}
	
	fileprivate init () {}
}
